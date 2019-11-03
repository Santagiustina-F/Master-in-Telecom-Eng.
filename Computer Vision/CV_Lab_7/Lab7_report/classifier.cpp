#include "classifier.h"

CascadeClassifierContainer::CascadeClassifierContainer(const std::string& xml_filename)
{
  init();
  m_xml_filename = xml_filename;
  if( !m_classifier.load( m_xml_filename) ){ printf("--(!)Error loading cars cascade classifier\n"); };
}

void CascadeClassifierContainer::init() {
  // TO-BE-COMPLETED
}

cv::Mat CascadeClassifierContainer::classify(const cv::Mat &frame) {
  cv::Mat result(frame.clone());
  std::vector<cv::Rect_< int >> boxes;
  m_classifier.detectMultiScale(frame,boxes, 1.1, 3, 0, cv::Size(), cv::Size());
  for (int i = 0; i < boxes.size(); i++)
  {
    cv::Scalar object_roi_color(0, 255, 0);
    cv::String className = "car";
    cv::rectangle(result, boxes[i], object_roi_color);
	 // cv::putText(result, className,  boxes[i].x + cv::Point(0, -2), cv::FONT_HERSHEY_SIMPLEX, 0.6, object_roi_color); // print recognized class

  }
  return result;
}


YOLOClassifierContainer::YOLOClassifierContainer(
    const cv::String& cfg_file,
    const cv::String& weights_file,
    const double confidence_threshold) :
  m_classes(std::vector<std::string>(1)),
  m_colors(std::vector<cv::Scalar>(1)),
  m_confidence_threshold(confidence_threshold)
{
  init();

  try {
    std::cout << "Model cfg: " << cfg_file << std::endl;
    std::cout << "Model cfg: " << weights_file << std::endl;
    m_net = cv::dnn::readNetFromDarknet(cv::String(cfg_file),
                                        cv::String(weights_file));
  }
  catch (cv::Exception& e) {
    std::cout << "WARNING: YOLOClassifier not initialized correctly!"
              << std::endl;
    std::cout << e.what() << std::endl;
  }
}

void
YOLOClassifierContainer::init() {
  m_classes[0] = "car";
  m_colors[0] = cv::Scalar(0, 0, 255);
}

cv::Mat
YOLOClassifierContainer::classify(const cv::Mat &frame) {
  cv::Mat input;
  cv::Mat result(frame.clone());

  cv::Mat blob = cv::dnn::blobFromImage(result, 1 / 255.F, cv::Size(416, 416),
                                        cv::Scalar(), true, false);

  std::vector<cv::String> classNamesVec = {"background",
                                           "aeroplane", "bicycle", "bird", "boat",
                                           "bottle", "car", "bus", "cat", "chair",
                                           "cow", "diningtable", "dog", "horse",
                                           "person", "person", "pottedplant",
                                           "sheep", "sofa", "train", "tvmonitor"};

  m_net.setInput(blob, "data");
  cv::Mat output = m_net.forward("detection_out");;

  for (int i = 0; i < output.rows; i++)
  {
    const int probability_index = 5;
    const int probability_size = output.cols - probability_index;
    float *prob_array_ptr = &output.at<float>(i, probability_index);

    size_t object_class = std::max_element(prob_array_ptr, prob_array_ptr
                                           + probability_size) - prob_array_ptr;
    float confidence = output.at<float>(i, (int)object_class
                                        + probability_index);

    if (confidence > m_confidence_threshold
        && object_class != 7)  //  exclude "bus" class
    {
      float x_center = output.at<float>(i, 0) * result.cols;
      float y_center = output.at<float>(i, 1) * result.rows;
      float width = output.at<float>(i, 2) * result.cols;
      float height = output.at<float>(i, 3) * result.rows;
      cv::Point p1(cvRound(x_center - width / 2),
                   cvRound(y_center - height / 2));
      cv::Point p2(cvRound(x_center + width / 2),
                   cvRound(y_center + height / 2));
      cv::Rect object(p1, p2);

      cv::Scalar object_roi_color(0, 255, 0);

      cv::rectangle(result, object, object_roi_color);
	  cv::putText(result, classNamesVec[object_class], p1 + cv::Point(0, -2), cv::FONT_HERSHEY_SIMPLEX, 0.6, object_roi_color); // print recognized class
    }
  }
  return result;
}
