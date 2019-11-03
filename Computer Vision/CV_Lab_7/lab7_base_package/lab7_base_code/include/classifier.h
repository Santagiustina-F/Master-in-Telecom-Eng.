#ifndef LAB7__CLASSIFIER___H
#define LAB7__CLASSIFIER___H

#include <iostream>

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/dnn.hpp>
#include <opencv2/dnn/shape_utils.hpp>
#include <opencv2/highgui.hpp>

class ClassifierContainer{
public:
  ClassifierContainer(){}
  virtual ~ClassifierContainer(){}

  virtual cv::Mat classify(const cv::Mat& frame) = 0;
protected:
  virtual void init() = 0;
};

class CascadeClassifierContainer : public ClassifierContainer {
public:
  CascadeClassifierContainer(const std::string& xml_filename);

  cv::Mat classify(const cv::Mat& frame) override;   //override specifier: underlines that the function is overriding a virtual method in the base class
protected:
  void init() override;

private:
  cv::CascadeClassifier m_classifier;
  std::string m_xml_filename;
};

class YOLOClassifierContainer : public ClassifierContainer {
public:
  YOLOClassifierContainer(const cv::String &cfg_file,
                          const cv::String &weights_file,
                          const double confidence_threshold);

  cv::Mat classify(const cv::Mat& frame) override;
protected:
  void init() override;

private:
  std::vector<std::string> m_classes;
  std::vector<cv::Scalar> m_colors;
  cv::dnn::Net m_net;
  const double m_confidence_threshold;
};


#endif // LAB7__CLASSIFIER___H
