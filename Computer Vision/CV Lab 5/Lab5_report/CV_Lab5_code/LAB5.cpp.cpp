#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/xfeatures2d.hpp>

 #include "panoramic_utils.h"
 #include "FeatureMatcher.h"
 #include "PanoramicImage.h"



 int main(int argc, char** argv)
 {
   using namespace std;
   using namespace cv;
   // read image into cv::Mat input_img and visualize

   String folderPath = argv[1];
   const double angle = atoi(argv[2]);
   int ratio = atoi(argv[3]);
   if (argc < 4) {
     String folderPath = "/home/francesco/Desktop/Computer Vision/CV Lab 5/kitchen/*.bmp";
     const double angle = 66; // or 54 for Dolomites pictures.
     int ratio = 5;
   };

   PanoramicImage myPI = PanoramicImage(folderPath, angle, ratio );
   Mat panorama = myPI.getResult();
   imwrite( "Panorama.jpg", panorama);

   cv::namedWindow("Visualization of the generated panorama", CV_WINDOW_AUTOSIZE);
   cv::imshow("Visualization of the generated panorama", panorama);
   waitKey(0);
   cv::destroyAllWindows();
   return 0;
 };
