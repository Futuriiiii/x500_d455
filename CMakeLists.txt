cmake_minimum_required(VERSION 3.0.2)
project(x500_d455)

find_package(catkin REQUIRED)

catkin_package(

)

include_directories(
	config
	launch
	models
	scripts
)
