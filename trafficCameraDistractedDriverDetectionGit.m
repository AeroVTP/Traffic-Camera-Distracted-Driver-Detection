function [] = trafficCameraDistractedDriverDetection(backgroundFrame, framesToProcess)
	
	%converting B to grayscale format before saving 
	B = rgb2gray(B);
	
	imwrite(B, 'afterconv2.PNG');
	
	%creating a Gaussian filter to blur the image	
	f_gauss = fspecial("gaussian", 1, 10);
	
	%applying the Gaussian filter to blur the image

	B = filter2(f_gauss, B, "valid");
	%returning back a string to make this appear to Octave as a function
	finished = 'done';
	
%this will never finish when this is turned into a live stream. 
end