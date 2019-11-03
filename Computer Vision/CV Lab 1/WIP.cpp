// include openCV and standard headers
#include <iostream>
#include <opencv2/opencv.hpp>

// window size
#define NEIGHBORHOOD_SIZE 9

// Thresholds on color differences
#define THRESH_R 50
#define THRESH_G 50
#define THRESH_B 50
#define THRESH_H 10



int main(int argc, char** argv)
{
  // read image into cv::Mat input_img and visualize
     
  cv::Mat img = cv::imread(argv[1]);
  cv::namedWindow("Visualiser", CV_WINDOW_AUTOSIZE);
  cv::imshow("Visualiser", img);
  cv::waitKey(0);
  cv::destroyWindow("Visualiser");
 
  // cv::setMouseCallback("img", onMouse, (void*)&img);
  // cv::waitKey(0);

  
  cv::destroyAllWindows();
  return 0;
}
