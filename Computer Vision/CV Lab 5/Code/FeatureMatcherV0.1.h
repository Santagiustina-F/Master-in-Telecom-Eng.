#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>

#include "panoramic_utils.h"

 using namespace std;
 using namespace cv;

 struct Features{
   std::vector<KeyPoint>& keypoints1;
   cv::OutputArray descriptors1;
   std::vector<KeyPoint>& keypoints2;
   cv::OutputArray descriptors2;
};

// Generic class implementing a filter with the input and output image data and the parameters
class FeatureMatcher{

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

  //Perform the cylindrical projection of the images
	void project(const double angle)
  {
    cv::Mat& i1 = img1;
    cv::Mat& i2 = img2;
    img1= PanoramicUtils::cylindricalProj(i1,angle);
    img2= PanoramicUtils::cylindricalProj(i2,angle);
  };

  // extract ORB features and describe them
  Features ORBExtractAndDescribe()
  {
    static Ptr<ORB> myORB = cv::ORB::create(500, 1.2f, 8, 31,0,2,ORB::HARRIS_SCORE, 31, 20);
    myORB.detectAndCompute(img1, kp1, desc1, false);
    myORB.detectAndCompute(img2, kp2, desc2, false);
    //Features ORBfeatures;
    //ORBfeatures.keypoints1 = kp1 ;
    //ORBfeatures.keypoints2 = kp2 ;
    //ORBfeatures.descriptors1 = desc1 ;
    //ORBfeatures.descriptors2 = desc2 ;
    //return ORBfeatures;
  };
  // extract SIFT features and describe them
  //Features cv::OutputArray SIFTfeatures();

	/* match the previously extracted and desctribed features, selecting the matches with distance less than
   ratio * min_distance, where ratio is a user defined threshold and min_distance is the minimum distance found
   among the matches.
   Return the */
  int matchFeatures(int ratio, Features feat)
  {
    static Ptr<BFMatcher> match = cv::BFMatcher::create( NORM_HAMMING,false);
    //Mat findHomography(InputArray srcPoints, InputArray dstPoints, int method=0, double ransacReprojThreshold=3, OutputArray mask=noArray() )
    return 7;
  };

	//Merge and display results
	cv::Mat getResult();

	// input images, may be projected cilindrically
	cv::Mat img1;
  cv::Mat img2;

  // Features and descriptors
  std::vector<KeyPoint> tmpkp1 = std::vector<KeyPoint>();
  std::vector<KeyPoint>& kp1  = tmpkp1;
  cv::OutputArray desc1;
  std::vector<KeyPoint>& kp2;
  cv::OutputArray desc2;

};
