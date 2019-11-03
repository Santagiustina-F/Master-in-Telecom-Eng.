#include <opencv2/opencv.hpp>
#include<iostream>
#include <dirent.h> 
using namespace std;
using namespace cv;

int main()
{
  String folder = "*.jpg";
  vector<String> filenames;
  glob(folder, filenames);
  cout<<filenames.size()<<endl;//to display no of files
  
  for(size_t i=0; i<filenames.size(),++i)
  {
    cout<<filenames[i]<<endl;
  }
}  