
// include openCV and standard headers
  #include "opencv2/core/core_c.h"
  #include "opencv2/core/core.hpp"
  #include "opencv2/flann/miniflann.hpp"
  #include "opencv2/imgproc/imgproc_c.h"
  #include "opencv2/imgproc/imgproc.hpp"
  #include "opencv2/video/video.hpp"
  #include "opencv2/features2d/features2d.hpp"
  #include "opencv2/objdetect/objdetect.hpp"
  #include "opencv2/calib3d/calib3d.hpp"
  #include "opencv2/ml/ml.hpp"
  #include "opencv2/highgui/highgui_c.h"
  #include "opencv2/highgui/highgui.hpp"
  #include <iostream>
  #include <opencv2/opencv.hpp>

  #include "filter.cpp"

  using namespace std;
  using namespace cv;

  // hists = vector of 3 cv::mat of size nbins=256 with the 3 histograms
  // e.g.: hists[0] = cv:mat of size 256 with the red histogram
  //       hists[1] = cv:mat of size 256 with the green histogram
  //       hists[2] = cv:mat of size 256 with the blue histogram
  void showHistogram(std::vector<cv::Mat>& hists)
  {
    // Min/Max computation
    double hmax[3] = {0,0,0};
    double min;
    cv::minMaxLoc(hists[0], &min, &hmax[0]);
    cv::minMaxLoc(hists[1], &min, &hmax[1]);
    cv::minMaxLoc(hists[2], &min, &hmax[2]);

    std::string wname[3] = { "blue", "green", "red" };
    cv::Scalar colors[3] = { cv::Scalar(255,0,0), cv::Scalar(0,255,0),
                             cv::Scalar(0,0,255) };

    std::vector<cv::Mat> canvas(hists.size());

    // Display each histogram in a canvas
    for (int i = 0, end = hists.size(); i < end; i++)
    {
      canvas[i] = cv::Mat::ones(125, hists[0].rows, CV_8UC3);

      for (int j = 0, rows = canvas[i].rows; j < hists[0].rows-1; j++)
      {
        cv::line(
              canvas[i],
              cv::Point(j, rows),
              cv::Point(j, rows - (hists[i].at<float>(j) * rows/hmax[i])),
              hists.size() == 1 ? cv::Scalar(200,200,200) : colors[i],
              1, 8, 0
              );
      }

      cv::imshow(hists.size() == 1 ? "value" : wname[i], canvas[i]);
    }
  }


/////////////////////////////////////////////////////////////////////////////
Mat target_image;
int ksM;
int ksM_max=100;
int ksG;
int ksG_max=100;
int ksB;
int ksB_max=100;
int sigma;
int sigma_max = 100;
int spatial_sigma;
int s_sigma_max=100;
int color_sigma;
int c_sigma_max=255;


/*
 * @function on_trackbar
 * @brief Callback for trackbar
 */
  void on_trackbar_median( int, void* )
  {
    MedianFilter MedianF = MedianFilter(target_image,ksM);
    MedianF.doFilter();
    imshow( "Median Filter", MedianF.getResult() ); // M_filt.getResult() );
  }

  void on_trackbar_gaussian( int, void* )
  {
    GaussianFilter GaussF = GaussianFilter(target_image,ksG, (double) sigma);
    GaussF.doFilter();
    imshow( "Gaussian Filter", GaussF.getResult()); // M_filt.getResult() );
  }
  void on_trackbar_bilateral( int,  void* )
  {
    BilateralFilter BilatF = BilateralFilter(target_image, 6*spatial_sigma,  (double)  color_sigma,  (double)  spatial_sigma);
    BilatF.doFilter();
    imshow( "Bilateral Filter", BilatF.getResult()); // M_filt.getResult() );
  }


//////////////////////////////////////////////////////////////////////////////


int main(int argc, char** argv)
{
  // read image into cv::Mat input_img and visualize

  cv::Mat img = cv::imread(argv[1]);
  //cv::namedWindow("Visualization of the chosen image", CV_WINDOW_AUTOSIZE);
  //cv::imshow("Visualization of the chosen image", img);
  //waitKey(0);
  //cv::destroyAllWindows();


  ////////////////////////////////////////////////Equalization of RGB channels///////////////////////////////////
  //Separating the three channels
  cv::Mat *ch1, *ch2, *ch3;
  vector<Mat> BGRchannels(3); // "channels" is a vector of 3 Mat arrays:
  cv::split(img, BGRchannels); // split img:
  // get the channels (dont forget they follow BGR order in OpenCV)
  ch1 = &BGRchannels[0];
  ch2 = &BGRchannels[1];
  ch3 = &BGRchannels[2];

  // Settting histograms parameters
  int nBins [1] = { 256 };
  float range[] = { 0, 255 } ;
  const float* histRange = { range };

  // Computing the original histograms
  cv::Mat histB , histG , histR; //histograms of each channel
  cv::calcHist(ch1,1, 0 , cv::Mat(), histB, 1, nBins, &histRange, true, false );
  cv::calcHist(ch2,1, 0, cv::Mat(), histG, 1, nBins, &histRange, true, false );
  cv::calcHist(ch3,1, 0, cv::Mat(), histR, 1, nBins, &histRange, true, false );

  //Creating a reference to the vector of histograms for future display
  std::vector<cv::Mat> originalHist;
  originalHist.push_back(histB);
  originalHist.push_back(histG);
  originalHist.push_back(histR);
  std::vector<cv::Mat>& ref_originalHist = originalHist;

      //Histogram equalization of each channel
  cv::Mat equalized1 , equalized2 , equalized3 ; // equalized channels
  cv::equalizeHist(*ch1,equalized1);
  cv::equalizeHist(*ch2,equalized2);
  cv::equalizeHist(*ch3,equalized3);
  cv::Mat *ch1_eq, *ch2_eq, *ch3_eq;
  ch1_eq = &equalized1;
  ch2_eq = &equalized2;
  ch3_eq = &equalized3;

  // Computing the equalized histograms
  cv::Mat eq_histB , eq_histG , eq_histR; //histograms of each channel
  cv::calcHist(ch1_eq,1, 0, cv::Mat(), eq_histB, 1, nBins, &histRange, true, false );
  cv::calcHist(ch2_eq,1, 0, cv::Mat(), eq_histG, 1, nBins, &histRange, true, false );
  cv::calcHist(ch3_eq,1, 0, cv::Mat(), eq_histR, 1, nBins, &histRange, true, false );

  //Creating a reference to the vector of histograms for future display
  std::vector<cv::Mat> equalizedHist;
  equalizedHist.push_back(eq_histB);
  equalizedHist.push_back(eq_histG);
  equalizedHist.push_back(eq_histR);
  std::vector<cv::Mat>& ref_equalizedHist = equalizedHist;


  //Merging the three channels back ogether
  std::vector<cv::Mat> array_to_merge;

  array_to_merge.push_back(equalized1);
  array_to_merge.push_back(equalized2);
  array_to_merge.push_back(equalized3);

  cv::Mat BGR_equalized;

  cv::merge(array_to_merge, BGR_equalized);

  /// Display original image and its histograms
  String source_window = "Original Image";
  namedWindow( source_window, CV_WINDOW_AUTOSIZE );
  imshow( source_window, img );
  showHistogram(ref_originalHist);

  waitKey(0); // Wait for any keystroke in any one of the windows

  /// Display equalized image and histograms

  String equalized_window = "Equalized BGR Components Histogram Image";
  namedWindow( equalized_window, CV_WINDOW_AUTOSIZE );
  imshow( equalized_window, BGR_equalized );
  showHistogram(ref_equalizedHist);

  waitKey(0); // Wait for any keystroke in any one of the windows


  ////////////////////////////////////////// Change color space to HSV and equalize /////////////////////////////////
  Mat HSV_img;
  cv::cvtColor(img, HSV_img, CV_RGB2HSV);

  //Split the image into 3 channels; H, S and V channels respectively
  vector<Mat> HSVchannels(3);
  cv::split(HSV_img, HSVchannels);
  cv::Mat *ch4;
  ch4 = &HSVchannels[2];
  //Compute the original histogram of the V channel
  cv::Mat histV;
  cv::calcHist(ch4,1, 0, cv::Mat(), histV, 1, nBins, &histRange, true, false );

  //Equalize only the V channel histogram
  cv::equalizeHist(HSVchannels[2], HSVchannels[2]);
  cv::Mat *eq_ch4;
  eq_ch4 = &HSVchannels[2];

  // Compute the equalized histogram
  cv::Mat eq_histV;
  cv::calcHist(eq_ch4,1, 0, cv::Mat(), eq_histV, 1, nBins, &histRange, true, false );

  //Merge 3 channels in the vector to form the color image in HSV color space.
  cv::Mat HSV_equalized;
  cv::merge(HSVchannels, HSV_equalized);

  //Convert the histogram equalized image from HSV to BGR color space again
  cv::cvtColor(HSV_equalized, HSV_equalized, CV_HSV2BGR);

  //Define the names of windows
  String windowNameOfOriginalImage = "Original Image";
  String windowNameOfBGR_equalized = "Equalized BGR Components Histogram Image";
  String windowNameOfHSV_equalized = "Brigthness (or value V of HSV) Histogram Equalized Image";

  // Create windows with the above names
  namedWindow(windowNameOfOriginalImage, CV_WINDOW_AUTOSIZE);
  namedWindow(windowNameOfBGR_equalized, CV_WINDOW_AUTOSIZE);
  namedWindow(windowNameOfHSV_equalized, CV_WINDOW_AUTOSIZE );

  // Show images inside the created windows.
  imshow(windowNameOfOriginalImage, img);
  imshow(windowNameOfBGR_equalized, BGR_equalized);
  imshow(windowNameOfHSV_equalized, HSV_equalized);

  waitKey(0); // Wait for any keystroke in any one of the windows

  imwrite( "/home/francesco/Desktop/OriginalImage.jpg", img );
  imwrite( "/home/francesco/Desktop/BGR_equalized.jpg",BGR_equalized );
  imwrite( "/home/francesco/Desktop/HSV_equalize.jpg", HSV_equalized );

  destroyAllWindows(); //Destroy all opened windows


  ///////////////////////////////////// Image denoising with trackbar implementation//////////////////////////////////////////

  target_image = BGR_equalized ;

  ksM = 0;
  ksG = 0;
  ksB = 0;
  sigma = 0;
  spatial_sigma = 0;
  color_sigma=0;

  namedWindow("Median Filter", 1);
  char Trackbar1Name[50];
  sprintf( Trackbar1Name, "Kernel size from 0 to %d", ksM_max );
  createTrackbar( Trackbar1Name, "Median Filter", &ksM, ksM_max, on_trackbar_median );
  on_trackbar_median( ksM, 0 );

  namedWindow("Gaussian Filter", 1);
  char Trackbar2Name[50];
  char Trackbar3Name[50];
  sprintf( Trackbar2Name, "Kernel size from 0 to %d",ksG_max );
  sprintf( Trackbar3Name, "Sigma from 0 to %d", sigma_max );
  createTrackbar( Trackbar2Name, "Gaussian Filter", &ksG, ksG_max, on_trackbar_gaussian );
  createTrackbar( Trackbar3Name, "Gaussian Filter", &sigma, sigma_max, on_trackbar_gaussian );
  on_trackbar_gaussian(ksG, 0);

  namedWindow("Bilateral Filter", 1);
  char Trackbar4Name[50];
  char Trackbar5Name[50];
  sprintf( Trackbar4Name, "Sigma space from 0 to %d", s_sigma_max);
  sprintf( Trackbar5Name, "Sigma colour from 0 to %d", c_sigma_max );
  createTrackbar( Trackbar4Name, "Bilateral Filter", &spatial_sigma, s_sigma_max, on_trackbar_bilateral );
  createTrackbar( Trackbar5Name, "Bilateral Filter", &color_sigma, c_sigma_max, on_trackbar_bilateral );
  on_trackbar_bilateral(spatial_sigma, 0);


  waitKey(0); /// Wait until user exits the program
  return 0;
}
