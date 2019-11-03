#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include "panoramic_utils.h"

 using namespace std;
 using namespace cv;

 // Structure

 struct Features{
   std::vector<KeyPoint> tmpkeypoints1 = std::vector<KeyPoint>();
   std::vector<KeyPoint>& keypoints1 = tmpkeypoints1;
   cv::_OutputArray descriptors1 = cv::Mat();
   std::vector<KeyPoint> tmpkeypoints2 = std::vector<KeyPoint>();
   std::vector<KeyPoint>& keypoints2 = tmpkeypoints2;
   cv::_OutputArray descriptors2 = cv::Mat();
 };


// Generic class implementing a filter with the input and output image data and the parameters
class FeatureMatcher{ //stitcher


// Methods

public:
  //Construcetor
  FeatureMatcher(const cv::Mat& image1,const cv::Mat& image2)
  {
    img1= image1.clone();
    img2= image2.clone();

    /*  Uncomment if cylindrical projection is mandatory
    i1& = img1;
    i2& = img2;
    const double angle = 33; // or 27 for Dolomites pictures.
    img1=PanoramicUtils.cylindricalProj(i1,angle):
    img2=PanoramicUtils.cylindricalProj(i2,angle);
    */
  };


  // extract ORB features and describe them
  Features ORBExtractAndDescribe()
  {
    static Ptr<ORB> myORB = cv::ORB::create(500, 1.2f, 8, 31,0,2,ORB::HARRIS_SCORE, 31, 20);
    int maskwidth = 50;
    Mat mask1 = Mat(Size(img1.cols ,img1.rows), img1.type(), 255);
    //mask1(Rect(0,0,maskwidth,img1.rows)) = 0;
    Mat mask2 = Mat(Size(img2.cols ,img2.rows), img2.type(), 255);
    //mask2(Rect(img2.cols-maskwidth,0,maskwidth,img1.rows)) = 0;
    //cv::imshow("Mask1", mask1);
    //cv::imshow("Mask2", mask2);
      //waitKey(0);
    (*myORB).detectAndCompute(img1, mask1, kp1, desc1, false);
    (*myORB).detectAndCompute(img2, mask2, kp2, desc2, false);

    Features ORBfeatures;
    ORBfeatures.keypoints1 = kp1 ;
    ORBfeatures.keypoints2 = kp2 ;
    ORBfeatures.descriptors1 = desc1 ;
    ORBfeatures.descriptors2 = desc2 ;

    //draw and display the features of A
    /*
    cv::Mat img_f1;
    cv::drawKeypoints(img1, kp1, img_f1);
    cv::namedWindow("Features of image A", CV_WINDOW_AUTOSIZE);
    imshow("Features of image A", img_f1 );

    //draw and display the features of B
    cv::Mat img_f2;
    cv::drawKeypoints(img2, kp2, img_f2);
    cv::namedWindow("Features of image B", CV_WINDOW_AUTOSIZE);
    imshow("Features of image B", img_f2 );
      waitKey(0);
    */

    return ORBfeatures;
  };


	// match the previously extracted and desctribed features

  Mat matchFeatures(int ratio, Features feats)
  {
    //find the matches


    BFMatcher matcher = cv::BFMatcher( NORM_HAMMING,false);
    std::vector<std::vector<cv::DMatch> > tmpmatches;
    std::vector<std::vector<cv::DMatch> >& matches = tmpmatches;
    matcher.add(feats.descriptors1);
    matcher.train();
    matcher.knnMatch( feats.descriptors2, matches , 1, noArray(),false );

    //draw and display the matches
    cv::Mat img_matches;
    cv::drawMatches(img1, feats.keypoints1 ,img2, feats.keypoints2 ,matches, img_matches);
    cv::namedWindow("Visualization of the matches between the two images", CV_WINDOW_AUTOSIZE);
    imshow("Visualization of the matches between the two images", img_matches );
      waitKey(0);

    //Filter the matches by selecting the matches with distance less than ratio * min_distance

    vector< DMatch > good_matches2; //just some temporarily code to have the right data structure
    good_matches2.reserve(matches.size());
    for (size_t i = 0; i < matches.size(); ++i)
    {
        good_matches2.push_back(matches[i][0]);
        //cout << " Im1 idx " << matches[i][0].trainIdx ;
        //cout << " Im2 idx " << matches[i][0].queryIdx ;
        //cout << " Distance " << matches[i][0].distance ;
    }

    //calculation of min distance between features descriptors
    double min_dist = 100;
    for( int i = 0; i < (feats.descriptors1).rows(); i++ )
    {
        double dist = good_matches2[i].distance;
          if( dist < min_dist ) min_dist = dist;
          //if (min_dist < 10) min_dist = 1;

    }
    cout << " \n" << "Minimum distance " << min_dist << " \n";;
    //find the "good" matches
    vector< DMatch > good_matches;

    for( int i = 0; i < (feats.descriptors1).rows(); i++ )
    {
      if( good_matches2[i].distance <= ratio * min_dist )
      {
          good_matches.push_back( good_matches2[i]);
          // std::cout << i << ' ';
      }
    }
    std::cout  << "Number of found good matches:" << good_matches.size() << '\n';

    if(good_matches.size() < 10)
    {
      std::cout << "The filtering of matches do not returned enough good matches, so the original ones are kept." << '\n';
      good_matches = good_matches2;
    };
    /*
    //draw and display the filtered matches (strange bugs originates here)
    cv::Mat img_fmatches;
    cv::drawMatches(img1, feats.keypoints1 ,img2, feats.keypoints2 ,good_matches, img_fmatches);
    cv::namedWindow("Visualization of the filterd matches between the two images", CV_WINDOW_AUTOSIZE);
    imshow("Visualization of the filterd matches between the two images", img_fmatches );
      waitKey(0);
    cv::destroyAllWindows();
    */
      //select the coordinates of filtered matching keypoints
      vector<Point2f> points1; vector<Point2f> points2;
      for( int i = 0; i < good_matches.size(); i++ )
      {
            points1.push_back( feats.keypoints1[good_matches[i].trainIdx].pt);
            points2.push_back( feats.keypoints2[good_matches[i].queryIdx].pt);
      }

    //Find the homography
    Mat homog = findHomography(points1, points2, CV_RANSAC , 5, noArray(), 75 ,0.995 );
    return homog;



  };

	// input images, may be projected cilindrically
	cv::Mat img1;
  cv::Mat img2;

  // Features and descriptors
  std::vector<KeyPoint> tmpkp1 = std::vector<KeyPoint>();
  std::vector<KeyPoint>& kp1  = tmpkp1;
  Mat desc1 = Mat() ;
  std::vector<KeyPoint> tmpkp2 = std::vector<KeyPoint>();
  std::vector<KeyPoint>& kp2 = tmpkp2;
  Mat desc2 = Mat() ;

};
