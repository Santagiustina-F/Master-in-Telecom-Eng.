#include <iostream>
#include <array>
#include <memory>

#include <opencv2/core.hpp>
#include <opencv2/video.hpp>
#include <opencv2/highgui.hpp>

#include "classifier.h"

static const char* params =
"{ help            | false | print usage                           }"
"{ yolo_cfg        |       | YOLO model configuration              }"
"{ yolo_weights    |       | YOLO model weights                    }"
"{ yolo_confidence | 0     | YOLO min confidence                   }"
"{ cascade_xml     |       | XML of the trained cascade classifier }";

struct ClassifierWithResult
{
  std::shared_ptr<ClassifierContainer> classifier;
  std::vector<cv::Mat> results;
};

int main(int argc, char** argv)
{
  cv::CommandLineParser parser(argc, argv, params);
  if (parser.get<bool>("help"))
  {
      parser.printMessage();
      return 0;
  }

  // reading parameters from the commmand line
  if (! (parser.has("cascade_xml") && parser.has("yolo_weights")
         && parser.has("yolo_cfg")))
  {
    std::cout << "FAILED TO READ MANDATORY CMD LINE ARGS!";
    std::cout << " you should specify the cascade_xml yolo_cfg and "
                 "yolo_weights cmd line args!";
    return 1;
  }

  cv::String cascade_xml = parser.get<cv::String>("cascade_xml");
  cv::String yolo_weights = parser.get<cv::String>("yolo_weights");
  cv::String yolo_cfg = parser.get<cv::String>("yolo_cfg");
  double yolo_confidence = parser.get<float>("yolo_confidence");

  // input
  std::vector<cv::VideoCapture> video_caps =
  {
    cv::VideoCapture("/home/francesco/Desktop/Computer Vision/CV_Lab_7/lab7_base_package/lab7_base_code/data/video.mp4")
  };

  // 0 = CascadeClassifier
  // 1 = YOLO
  std::array<ClassifierWithResult, 2> classifiers;
  classifiers[0].classifier = std::make_shared<CascadeClassifierContainer>
      (cascade_xml);
  classifiers[1].classifier = std::make_shared<YOLOClassifierContainer>
      (cv::String(yolo_cfg), cv::String(yolo_weights), yolo_confidence);

  int fr_id = 0;
  for (auto& video_cap : video_caps)
  {
    cv::Mat frame;
    while(video_cap.read(frame))
    {
      int cl_id = 0;

      for (auto& classifier : classifiers)
      {
        std::cout << "Classifier " << cl_id++
                  << ": Classifying frame " << fr_id << " ..." << std::flush;
        classifier.results.push_back(classifier.classifier->classify(frame));
        std::cout << " Done!" << std::endl;
      }
      fr_id++;
    }
  }

  cv::namedWindow("video");
  std::vector<cv::Mat> to_show (classifiers.size() * 2 - 1);
  for (int i = 0, end = classifiers[0].results.size(); i < end; ++i)
  {
    for (int k = 0, end_k = classifiers.size() - 1; k < end_k; ++k)
    {
      to_show[k * 2] = classifiers[k].results[i];
      to_show[k * 2 + 1] = cv::Mat(to_show[k * 2].rows, 20, CV_8UC3,
                                cv::Scalar(0,0,0));
    }
    to_show[(classifiers.size() - 1) * 2] = classifiers.back().results[i];

    cv::Mat dst;
    cv::hconcat(to_show, dst);
    cv::imshow("video", dst);
    cv::waitKey(30);
  }
  cv::destroyAllWindows();

  return 0;
}
