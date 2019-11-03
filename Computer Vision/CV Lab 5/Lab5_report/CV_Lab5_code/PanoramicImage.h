#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>

// Generic class implementing a filter with the input and output image data and the parameters
class PanoramicImage{

// Methods

public:

	// constructor
  //folderPath is the path of the folder containing the images to be loaded
	PanoramicImage(String imagesPathPattern, double fieldOfViewAngle, int filterMatchingRatio)
  {
    hFoV = fieldOfViewAngle/2.0;
    FMratio  = filterMatchingRatio;
    vector<String> filenames;
    glob(imagesPathPattern, filenames);
    cout<< "Number of files found : " << filenames.size()<<endl;//to display no of files

    for(size_t i=0; i<filenames.size();++i)
    {
    input_images.push_back(PanoramicUtils::cylindricalProj(cv::imread(filenames[i]),hFoV));
    /*
    cv::namedWindow("Visualization of the chosen images", CV_WINDOW_AUTOSIZE);
    cv::imshow("Visualization of the chosen images", input_images[i]);
    waitKey(0);*/

    }
  };

	Mat getResult()
  {
    computeHomographies();
    result_image = input_images[0];
    for(size_t j=0; j<input_images.size()-1;++j)
    {
       result_image = concatenate(result_image, input_images[j+1],homographies[j]);
    std::cout << "concatenate" << j+1 << '\n';
    }

    return result_image;
  };

// Data and internal methods

protected:

  void computeHomographies()
  {
    for(size_t j=0; j<input_images.size()-1;++j)// index representing the number of ordered successive couples
    {
      cout <<  " \n" << "Computing homography " << j+1  << " \n";
      cv::Mat imgA = input_images[j];
      cv::Mat imgB = input_images[j+1];
      /*
      cv::namedWindow("Visualization of the chosen image A", CV_WINDOW_AUTOSIZE);
      cv::imshow("Visualization of the chosen image A", imgA);
      cv::namedWindow("Visualization of the chosen image B", CV_WINDOW_AUTOSIZE);
      cv::imshow("Visualization of the chosen image B", imgB);
      waitKey(0);
      cv::destroyAllWindows();
      */

      const cv::Mat& iA = imgA;
      const cv::Mat& iB = imgB;

      FeatureMatcher FM = FeatureMatcher(iA,iB);
      Features ObtainedFeatures = FM.ORBExtractAndDescribe();
      homographies.push_back( FM.matchFeatures(FMratio,ObtainedFeatures));
      cout << "Homography " << j+1 << " computed : " << " \n";
      cout << homographies[j] << " \n";

    }
  };

    Mat concatenate(Mat img1, Mat img2, Mat homography)
    {
      int deltaX = abs(homography.at<double>(cv::Point(2,0)));
      X = X + homography.at<double>(cv::Point(2,0));
      int deltaY = abs(homography.at<double>(cv::Point(2,1)));
      Y = Y + homography.at<double>(cv::Point(2,1));
      homography.at<double>(cv::Point(2,1)) = Y;
      Y=0;
      Mat h = (Mat_<double>(3,3) << 1, 0, X, 0, 1, Y, 0, 0, 1);
      Mat result;
      // cout<<h<<endl;

      warpPerspective(img2, result, h.inv(), Size(img1.cols + deltaX, img1.rows));

      Mat roi1(result, Rect(0, 0, img1.cols, img1.rows));
      img1.copyTo(roi1);
      namedWindow("I3", WINDOW_NORMAL);
      imshow("I3",result);
      imwrite("result.jpg",result);
      waitKey();

      return result;
    };

	// vector of input images
	std::vector<Mat> input_images;

  // vector of homographies
  std::vector<Mat> homographies;
	// output image (filter result)
	cv::Mat result_image;

  // half field of view angle, to be passed to pro
	double hFoV = 0;

  // selecting the matches with distance less than ratio * min_distance
	int FMratio = 1;

  double X = 0;
  double Y = 0;

};
