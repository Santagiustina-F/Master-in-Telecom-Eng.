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

// called when mouse is clicked
void onMouse( int event, int x, int y, int f, void* userdata){

  // If the left button is pressed
  if (event == cv::EVENT_LBUTTONDOWN)
  {
    
    // Retrieving the image from the main 
    // How to get the data from void* userdata ? 
	// 1) Need a cast from void* back to cv::Mat*
	// 2) Be careful, it is a void* not a void !! Need to get the pointed data
	
	//cv::Mat image =  ????
	
	// need to clone to avoid overwriting input data
    cv::Mat image_out = image.clone();

    // Mean on the neighborhood
    
    // write your code



    // Color segmentation
    
    // write your code

    cv::imshow("final_result", image_out);
    cv::waitKey(0);
  }

}

int main(int argc, char** argv)
{
  // read image into cv::Mat input_img and visualize
     
  cv::Mat img = cv::imread("roma.jpeg");
  cv::namedWindow("Visualiser", CV_WINDOW_AUTOSIZE);
  cv::imshow("Visualiser", img);
  cv::waitKey(0);
  // cv::destroyWindow("Visualiser");
 
  // cv::setMouseCallback("img", onMouse, (void*)&img);
  // cv::waitKey(0);

  
  
  return 0;
}


