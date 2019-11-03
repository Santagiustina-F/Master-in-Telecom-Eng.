#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include "filter.h"

//using namespace cv;

	// constructor
	Filter::Filter(cv::Mat input_img, int size) {

		input_image = input_img;
		if (size % 2 == 0)
			size++;
		filter_size = size;
	}

	// for base class do nothing (in derived classes it performs the corresponding filter)
	void Filter::doFilter() {

		// it just returns a copy of the input image
		result_image = input_image.clone();

	}

	// get output of the filter
	cv::Mat Filter::getResult() {

		return result_image;
	}

	//set window size (it needs to be odd)
	void Filter::setSize(int size) {

		if (size % 2 == 0)
			size++;
		filter_size = size;
	}

	//get window size
	int Filter::getSize() {

		return filter_size;
	}



	// Write your code to implement the Gaussian, median and bilateral filters

	// Gaussian Filter

		GaussianFilter::GaussianFilter(cv::Mat input_img, int kernel_size, double std_dev) : Filter::Filter(input_img, kernel_size)
		{
			sigma = std_dev;
		}

		void GaussianFilter::doFilter() {
			result_image = input_image.clone();
			cv::GaussianBlur(input_image, result_image, cv::Size(filter_size,filter_size) , sigma);
		}

	 // Median Filter

	 	MedianFilter::MedianFilter(cv::Mat input_img, int kernel_size) : Filter::Filter(input_img, kernel_size) {}


	 	void MedianFilter::doFilter()	{
			result_image = input_image.clone();
			cv::medianBlur(input_image, result_image, filter_size);
		}

	 // Bilateral Filter

	 BilateralFilter::BilateralFilter(cv::Mat input_img, int kernel_size, double range_std_dev, double spatial_std_dev) :
	 																																					Filter::Filter(input_img, kernel_size)
		{
		sigma_range	= range_std_dev;
		sigma_space = spatial_std_dev;
		}


		void BilateralFilter::doFilter()	{
			result_image = input_image.clone();
			cv::bilateralFilter(input_image, result_image, filter_size, sigma_range, sigma_space);
		}
