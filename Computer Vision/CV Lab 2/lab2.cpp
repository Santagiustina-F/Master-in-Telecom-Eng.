// include openCV and standard headers
#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;
using namespace std;

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
  vector<String> filenames; 
  String folder = "*.jpg"; 
  glob(folder, filenames);
  cout<<filenames.size()<<endl;//to display no of files
  
  for(size_t i=0; i<filenames.size();++i)
  {
    cout<<filenames[i]<<endl;
    cv::Mat img = cv::imread(filenames[i]); // std::to_string(i)+".jpg"
    cv::namedWindow("Visualiser", CV_WINDOW_AUTOSIZE);
    cv::imshow(“Image”, img);
    cv::waitKey(0);
    cv::destroyWindow("Visualiser");
  }
  // cv::setMouseCallback("img", onMouse, (void*)&img);
  // cv::waitKey(0);

  
  
  return 0;
}


