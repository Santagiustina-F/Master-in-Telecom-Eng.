#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/features2d.hpp>


using namespace std;
using namespace cv;


 int main(int argc, char** argv)
 {

   // import and visualize images

   String PicturesPath = argv[1];


   PicturesPath = "./dataset/*.png";


   std::vector<Mat> depth_input_images; // vector of color input images
 	 std::vector<Mat> color_input_images; // vector of color input images
   vector<String> Filenames;
   glob(PicturesPath,Filenames);
   cout<< "Number of GBR-D pictures found : " << Filenames.size()/2 <<endl;//to display no of files

   for(int i=0; i<Filenames.size()/2;++i)
   {

     depth_input_images.push_back(cv::imread(Filenames[i],CV_LOAD_IMAGE_ANYDEPTH)); // 16UC1 version
     //cout << " \n"  << "Type of depth input" << depth_input_images[i].type() << " \n" << "Channels" << depth_input_images[i].channels() ;
     color_input_images.push_back(cv::imread(Filenames[i+Filenames.size()/2]));

     /*
     cv::namedWindow("Visualization of the depth images", CV_WINDOW_AUTOSIZE);
     cv::imshow("Visualization of the depth images", depth_input_images[i]);
     cv::namedWindow("Visualization of the color images", CV_WINDOW_AUTOSIZE);
     cv::imshow("Visualization of the color images", color_input_images[i]);
     waitKey(0);
     */

    }


   cv::destroyAllWindows();


   std::vector<Mat> foreground;
   std::vector<Mat> normalized_foreground;
   std::vector<Mat> color_foreground;
   std::vector<Mat> thresholded_depth;
   std::vector<Mat> morph_opening_depth;
   std::vector<Mat> morph_closure_depth;
   std::vector<Mat> morph_dilate_depth;
   std::vector<Mat> normalized_images;
   std::vector<Mat> normalized_peoples;
   std::vector<Mat_<cv::Vec3f>> depth3Dimages;
   std::vector<Mat> color_with_rect;
   std::vector<Mat> final_result;


   for(int i=0; i<depth_input_images.size();++i)
   {
     cout << " \n"  << "Processing pair n° " << i  << " \n" ;

     // Background depth substraction
     foreground.push_back(depth_input_images[0]- depth_input_images[i]); // /!\ black and white inversion
     //cv::imshow("Background depth substraction", foreground[i]);


     double min;
     double max;
     cv::minMaxIdx(foreground[i], &min, &max);
     cv::Mat normalized_image;
     foreground[i].convertTo(normalized_image,CV_8UC1, 255 / (max-min), -255*min/(max-min));
     cv::imshow("Normalized foreground of depth images", normalized_image);
     normalized_foreground.push_back(normalized_image);


     // Morphological operations and thresholding on the depth map
     Mat morph;
     threshold( normalized_foreground[i], morph, 10 , 255, 3 ); // CV_THRESH_BINARY
     thresholded_depth.push_back(morph.clone());
     //cv::imshow("Thresholded depth image.", morph );


     Mat kernel1 = cv::getStructuringElement(MORPH_ELLIPSE, Size(10,10));
     morphologyEx(morph, morph, MORPH_OPEN, kernel1);
     morph_opening_depth.push_back(morph.clone());
     //cv::imshow("Morph. opening of depth image.", morph );
     Mat kernel2 = cv::getStructuringElement(MORPH_ELLIPSE, Size(5,5));
     morphologyEx(morph, morph, MORPH_CLOSE, kernel2);
     morph_closure_depth.push_back(morph.clone());
     //cv::imshow("Morph. closing of  depth image.", morph );
     morphologyEx(morph, morph, MORPH_DILATE, kernel1,  Point(-1,-1), 3 );
     morph_dilate_depth.push_back(morph.clone());
     //cv::imshow("Sure background in black", morph);


     //I want to recover information lost when the "background depth" was subtracted to frames

     cv::minMaxIdx(depth_input_images[i], &min, &max);
     Mat diff = (max-depth_input_images[i]);
     diff.convertTo(normalized_image,CV_8UC1, 255 / (max-min), -255*min/(max-min));
     cv::namedWindow("Normalized depth images", CV_WINDOW_AUTOSIZE);
     cv::imshow("Normalized depth images", normalized_image);
     normalized_images.push_back(normalized_image);

     // I apply as a mask the area where I have recognized that there are people
     threshold(morph_closure_depth[i], morph, 10, 255, 0 );
     //cv::imshow("Mask", morph);
     morph = morph.mul(normalized_images[i]/225);
     threshold(morph, morph, 10, 255, 3 );
     cv::imshow("Filtered depth map", morph);
     normalized_peoples.push_back(morph.clone());
     //imshow("Normalized peoples", normalized_peoples[i]);

     //                                       BLOB DETECTION

       vector<vector<Point> > blob_contours;
        vector<vector<int>> hierarchy;
        Mat drawing = Mat::zeros( normalized_peoples[i].size(), CV_8UC3 );
           Mat im_with_blob_keypoints = Mat::zeros( normalized_images[i].size(), CV_8UC3 );
           cvtColor(normalized_images[i], drawing, CV_GRAY2RGB);

           int peopleCount = 0;


           // Find blobs
           vector<KeyPoint> blob_keypoints;
           SimpleBlobDetector::Params params;


           // Filter by color
           params.filterByColor = false;
           params.blobColor = 255;

           // Change thresholds - depth
           params.minThreshold = 0;
           params.maxThreshold = 1000;

           // Filter by Area.
           params.filterByArea = true;
           params.minArea = 5000;
           params.maxArea = 40000;

           // Filter by Circularity
           params.filterByCircularity = true;
           params.minCircularity = 0.1;

           // Filter by Convexity
           params.filterByConvexity = true;
           params.minConvexity = 0.87;

           // Filter by Inertia
           params.filterByInertia = true  ;
           params.minInertiaRatio = 0.01;


           cv::Ptr<SimpleBlobDetector> detector = cv::SimpleBlobDetector::create(params);
           detector->detect( normalized_peoples[i], blob_keypoints );

           cout << "blob_keypoints # " << blob_keypoints.size() << endl;

           // Draw markers
           for ( int i = 0; i < blob_keypoints.size(); i++ ) {
     	       cv::circle( drawing, cv::Point(blob_keypoints[i].pt.x, blob_keypoints[i].pt.y), 10, Scalar(0,0,255), 4 );
           }
           peopleCount = blob_keypoints.size();



     //                                 DISTANCE TRANSFORM

     // I take a slice of the resulting depthmap
     threshold(morph, morph, 200, 255, 2 ); // Set max
     threshold(morph, morph, 140, 255, 3 ); // Set min ( 140 to detect peoples bust)
     morphologyEx(morph, morph, MORPH_OPEN, kernel1);
     cv::imshow("Sliced depthmap", morph);



     Mat dist_trans;
     //threshold( morph, morph, 1 , 255, 0 );
     //cv::imshow("Thresholded morph", morph);
     distanceTransform(morph,dist_trans,DIST_L2 ,5);
     normalize(dist_trans, dist_trans, 0, 1., NORM_MINMAX);
     cv::imshow("Distance transform", dist_trans);
     Mat thr_dist_trans;
     threshold( dist_trans,thr_dist_trans, 0.2 , 255, 0 );
     morphologyEx(thr_dist_trans,thr_dist_trans, MORPH_OPEN, kernel1);
     //cv::imshow("Thr. distance transform", thr_dist_trans);
     //Mat kernel1 = cv::getStructuringElement(MORPH_ELLIPSE, Size(20,20));
     //morphologyEx(dist_trans,dist_trans, MORPH_ERODE, kernel1,  Point(-1,-1), 5 );
     //cv::imshow("Eroded distance transform", dist_trans);


     //                     Normalize by connected components the distance transform

     Mat normConCmp = Mat::zeros(dist_trans.size(), dist_trans.type());
     Mat dist_8u;
     thr_dist_trans.convertTo(dist_8u, CV_8U);
     vector<vector<Point> > contours;
     findContours(dist_8u, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
     Mat markers = Mat::zeros(dist_trans.size(), CV_32SC1);
     vector<Mat> connectedComponents;
     Mat connectedComponent = Mat::zeros(dist_trans.size(), CV_32SC1);
     for (size_t i = 0; i < contours.size(); i++){
          Mat connectedComponent = Mat::zeros(dist_trans.size(), CV_32SC1);
          drawContours(markers, contours, static_cast<int>(i), Scalar::all(static_cast<int>(i)+1), -1);
          drawContours(connectedComponent, contours, static_cast<int>(i), Scalar::all(static_cast<int>(i)+1), -1);
          connectedComponent = connectedComponent * 10000 ;
          connectedComponent.convertTo(connectedComponent, CV_8U);
          threshold(connectedComponent,connectedComponent, 0 , 255 , 0 ); // I create a mask selcting the connected component
          connectedComponents.push_back(connectedComponent);
          connectedComponent.convertTo(connectedComponent, dist_trans.type());
          connectedComponent= connectedComponent.mul(dist_trans/255);
          normalize(connectedComponent, connectedComponent, 0, 1., NORM_MINMAX);
          //imshow("Normalized connected component of the distance transform", connectedComponent);
          normConCmp = normConCmp + connectedComponent;
        }

     imshow("Distance transform normalized by connected components", normConCmp);
     threshold( normConCmp,normConCmp, 0.7 , 255, 0 );
     Mat kernel3 = cv::getStructuringElement(MORPH_ELLIPSE, Size(3,3));
     morphologyEx(normConCmp,normConCmp, MORPH_OPEN, kernel3);
     morphologyEx(normConCmp,normConCmp, MORPH_DILATE, kernel2);
     //cv::imshow("Thr. norm. dist. trans", normConCmp);

     //                      Create the seed image for the watershed algorithm
     markers = Mat::zeros(normConCmp.size(), CV_32SC1);
     normConCmp.convertTo(dist_8u, CV_8U);
     findContours(dist_8u, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
     Mat seed = Mat::zeros(normConCmp.size(), CV_32SC1);
     for (size_t i = 0; i < contours.size(); i++){
          Mat connectedComponent = Mat::zeros(dist_trans.size(), CV_32SC1);
          drawContours(markers, contours, static_cast<int>(i), Scalar::all(static_cast<int>(i)+1), -1);
          drawContours(seed, contours, static_cast<int>(i), Scalar::all(static_cast<int>(i)+1), -1);
          cv::namedWindow("Seed regions", CV_WINDOW_AUTOSIZE);
          //imshow("Seed regions",seed*10000);
          // waitKey(0);
        }
      circle(markers, Point(5,5), 3, CV_RGB(255,255,255), -1);   // Draw the background marker
      imshow("Seed regions", markers*10000);

      // Perform the watershed algorithm

  Mat src_8UC3 = Mat(normalized_peoples[i].size(),CV_8UC3);
  Mat src_8UC1;
  normalized_peoples[i].convertTo(src_8UC1,CV_8UC1);
  cvtColor( src_8UC1, src_8UC3, COLOR_GRAY2RGB);
  src_8UC3 = src_8UC3.mul(color_input_images[i]/255); // remove to use only depth data
  imshow("src_8UC3", src_8UC3);
  markers.convertTo(markers, CV_32SC1);
  if (src_8UC3.type() == CV_8UC3){
    if (markers.type() == CV_32SC1){
    watershed(src_8UC3, markers);
  }}



  Mat mark = Mat::zeros(markers.size(), CV_8UC1);
  markers.convertTo(mark, CV_8UC1);
  bitwise_not(mark , mark);

  //imshow("Markers_v2",  mark); // uncomment this if you want to see how the mark
                              // image looks like at that point
  // Generate random colors
  vector<Vec3b> colors;
  for (size_t i = 0; i < contours.size(); i++)
  {
    int b = theRNG().uniform(0, 255);
    int g = theRNG().uniform(0, 255);
    int r = theRNG().uniform(0, 255);
    colors.push_back(Vec3b((uchar)b, (uchar)g, (uchar)r));
  }
  // Create the result image
  Mat dst = Mat::zeros(markers.size(), CV_8UC3);
  std::vector<Mat> segments;
  for(int l = 0; l < contours.size(); l++)
  {
    Mat segment = Mat(markers.size(), CV_8UC3, (0,0,0));
    segments.push_back(segment.clone());
  }
  std::vector<int> indexes;

  // Fill labeled objects with random colors
  for (int m = 0; m < markers.rows; m++)
  {
      for (int n = 0; n < markers.cols; n++)
      {
        int index = markers.at<int>(m,n);
        if (index > 0 && index <= static_cast<int>(contours.size()))
        {
            dst.at<Vec3b>(m,n) = colors[index-1];
            segments[index-1].at<Vec3b>(m,n)= Vec3b((uchar)255, (uchar)255, (uchar)255);
        }
        else
            dst.at<Vec3b>(m,n) = Vec3b(0,0,0);
      }
  }
  // Visualize the segmented image
    imshow("Segmented image", dst);


    // Drawing bounding boxes

    std::vector<Rect> boundRects;
    //cv::namedWindow("Segments", CV_WINDOW_AUTOSIZE);
    color_with_rect.push_back(color_input_images[i].clone());
    for(int l = 0 ; l < segments.size(); l++){

      morphologyEx(segments[l],segments[l], MORPH_OPEN, kernel3);
      morphologyEx(segments[l],segments[l] , MORPH_DILATE, kernel2);
      //imshow("Segments",segments[l]);
      //waitKey(0);
      cvtColor(segments[l],segments[l], CV_BGR2GRAY);
      vector<vector<Point> > contours2;
      findContours(segments[l], contours2, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);

      Rect boundRect= boundingRect(Mat(contours2[0]));
      boundRects.push_back(boundRect);
      rectangle(drawing, boundRect.tl(), boundRect.br(),(255,255,255), 2, 8, 0);
      //rectangle(color_with_rect[i], boundRect.tl(), boundRect.br(),(255,0,0), 2, 8, 0);
    }
    peopleCount = std::max(segments.size(),blob_keypoints.size());
    putText(drawing, "Count = "+to_string(peopleCount), cv::Point(20, 20), FONT_HERSHEY_PLAIN, 1, Scalar(0, 0, 0));
    putText(drawing, "Blob detection", cv::Point(400, 270), FONT_HERSHEY_PLAIN, 1, Scalar(0, 0, 255));
    putText(drawing, "Watershed segmentation", cv::Point(400, 290), FONT_HERSHEY_PLAIN, 1, Scalar(255, 0, 0));
    final_result.push_back(drawing);
    imshow("Final result", final_result[i]);
    // imshow("Color with rects",color_with_rect[i]);

    //imwrite( "/home/francesco/Desktop/Computer Vision/Projects/T2/results/result_image.png ",normalized_peoples[i] );
    cout << "There are maximum " << peopleCount  << " full standing persons in this frame.";
    waitKey(0);
 } // End of for cycle over images

  waitKey(0);
  return 0;
}; // end of main()
