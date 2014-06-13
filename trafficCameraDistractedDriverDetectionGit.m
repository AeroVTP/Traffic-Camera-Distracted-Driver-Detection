%Traffic Camera Distracted Driver Detection Algorithm 
%
%TCD^3
%
%This algorithm uses several image processing algorithms and techniques: 
%Convolution for blurring, Gaussian Bell Curve for blurring, 
%Morphology Techniques: Dilation and Erosion, and Region Props Blob Detection
%
%Requires Octave, a free Computational Engine, with the free Image package from Octave - Forge 
%
%Created by Vidur T. Prasad in partnership with the Air Force Research Lab's Discovery Lab
%at Tec^Edge Innovation and Collaboration Center
%
%This code cannot be used without explicit permission from Vidur T. Prasad

function [] = trafficCameraDistractedDriverDetection(backgroundFrame, framesToProcess)
	%backgroundFrame is the empty frame
	%framesToProcess is the last of the frames for processing
	
	%broad st. i optimum is 1941
	
	%loading image processing package 
	pkg load image
	
	%navigate to frames 
	cd 'C:\Users\Disc-1119\Desktop\Internships\Tracking\Octave\roadhighquallowfps\highquallowfps (6-11-2014 10-53-14 AM)';
	
	%converting i to string to allow for imread
	i = num2str(backgroundFrame); 
	
	%saving first image to allow for reverse calculation
	B = imread(i, 'jpg');
	
	%converting B to grayscale format before saving 
	B = rgb2gray(B);
			
	%preprocessing one time constants to be saved
	
	%creating a filter to blur the image
	avg_filter = 1/100 * ones(5);

	%actually blurring the background using convolution 
	B = conv2(avg_filter, B);
		
	%converting the image back into manipulatable formats
	B = uint8(B);
	
	%saving the background image
	imwrite(B, 'background.PNG');
					
	%saving row and column sizes for images
	S = size(B);
	SR = S(1);
	SC = S(2); 	
		
		
	%give initial process headstart of 1 to analyze two images neccesary.
	
		%allowing system to loop and analyze each image for the length of the number of available frames
		%should start at frame 2 to allow going backward
		for i = 1:framesToProcess
				
			y = i - 2;	
`
			%converting i to a string so that it can be used in the imread function
			istr = num2str(i);
			
			%reading in the current rev number's image
			M = imread(istr, 'jpg');
					
			%converting RGB image with 3D matrix encoding to 2D grayscale matrix, allowing for further manipulation
			M = rgb2gray(M);
						
			%actually blurring the images
			M = conv2(avg_filter, M);

			%converting the images back into manipulatable formats
			M = uint8(M);
					
			%finding the difference in the two images
			M = B - M;
			
			%threshold the image to get rid of noise and then saving it for later viewing
			M = (M <= 10);
			
			%use morphology techniques to clean up the image and get a more solid read on the objects of interest
		
			%dilate the image  					
			M = bwmorph(M, 'dilate', 5); 
			
			%eroding the image to counteract some of the harmful effects of dilation and to get a better read	
			M = bwmorph(M, 'erode',  5);			
					
			%get the perimeter boundaries of all of the blobs/features
			M = bwmorph(M, "remove");
			
			%remove outline around image
			%delete the outline columns and rows to remove outline from bwmorph(remove), 
			%the 1 first row and column and last column and row are removed
			M([1, SR], :) = [];
			
			M(:, [1, SC]) = [];
			
			%get each of the different blobs labelled as different numbers
			[M, blob] = bwlabel(M);
			
			%multiply blob number by 2 since there will be two spots to be filled in for loop, row and column
			blob = blob * 2;
			
			%set V so that incrementing system is set for for loop
			V = 0;		
			
			%run a loop to go through all the blobs, and use the max amount
			%to tell how many blobs are present
				while V < blob 
			
					%if else statement to deal with special scenario where V = 0, sets up O to be used 
					if  V == 0
						
						%lets even number jumping start with 1 since 0/2 will throw error
						O = 1;
					
					else 
						
						%make variable O to increment by 1 every step while letting V to increment by 2 
						O = V/2;
					
					endif; 
					
					%find all of the indices of the specific blob
					[r, c] = find (M == O);				
					
					%find the size of the object by looking at the number of row coordinates around the shape 
					Sr = rows(r);
					
					%if the blob is too small to qualify as a object that we know is a car
					if Sr <= 10
						%do nothing and go back to the next run of the while loop
						V = V + 2;
						C = ones(10)		
					%if it is big enough, do the rest of the operations 
					else 
											    
						%get the mean of all of the row coordinates to get the center coordinate
						S2 = mean(r);
					
						%get the mean of all of the row coordinates to get the center coordinate
						S3 = mean(c);	
					
						%save the coordinates for row into a matrix 
						C(O) = S2;
					
						%save the coordinates for column into a matrix
						C(O + 1) = S3;
					
						%increment by two so that same spot in matrix is not written into twice
						V = V + 2;
					
					endif;
					
				end;
			
			%create string name for file that matrix will be saved in 
			N = strcat(istr, 'matrix'); 
			
			%save the matrix as a file
			dlmwrite(N, C);
				
			%saving the final outlined image 
			imwrite(M, istr, 'PNG');
			
			%%%%%BEGIN DELTA CALCULATOR%%%%%			
	
		if y >= 2
	
			%check if this is initial run to load previous frame
			if y == 2
			
				%tmp message for debugging
				wentintointial = 'went into initial';
			
				%create another variable that can be manipulated with effecting loop counter
				V = y - 1;
		
				%convert V to a string so that it works in 'load'
				V = num2str(V);
			
				%create string to calculate name of file
				N = strcat(V, 'matrix');
		
				%read in the contents of the previous vector from the file
				prev_tmp = load(N);
			
				%convert i to string so that it works in 'load'
				V = num2str(y);
			
				%create string to calculate name of file
				N = strcat(V, 'matrix');
			
				%read in the contents of the current vector from the file
				tmp = load(N);
		
			%for all the other normal times that the algorithm is used
			else 		
		
				%tmp message for debugging
				wentintodebug = 'went into else statement should see this multiple times';
			
				%loading current tmp file into prev_tmp 
				%so that it can be compared with the next 
				prev_tmp = tmp;
		
				%convert V to a string so that it works in load
				V = num2str(y);
		
				%create string to calculate name of file
				N = strcat(V, 'matrix');
		
				%read in the contents of the current vector from the file
				tmp = load(N);
		
			endif; 
		
			%finding the size of the vector 
			St = size(tmp);
			Sp = size(prev_tmp);
	
			%if statement to skip correction step if both vectors are same size
			if St != Sp
		
				%tmp message for debugging
				wentintolengthcorrector = 'went into length corrector';
			
				% correct the length difference
				Stmp = St - Sp
			
				%create a switch to determine how to correct for size difference
				switch (Stmp)
						
					%if only one new car has been added, 
					%calculate which coordinates are the new car 
					case Stmp == 2
				
						%tmp message for debugging
						wentintocasetwo = 'went into case number 2';
					
							%calculate size of the large matrix to be able to step through it.
						if (St > Sp)
							
											
							%setting X to equal smaller vector to not throw an error
							S = Sp;
							
							%setting vector to equal size of larger one 
							SL = St; 
													
						else 
							
							V = 1; 
							
							%setting X to equal smaller vector to not throw an error
							S = St;
							
							%setting vector to equal size of larger one 
							SL = Sp; 
													
						endif
				
				%breaking the switch since it is already ready to go to the next step
				endswitch 
												
				%analysing the length of the coordinate vector
				for a = 2:S
					
					%calculate difference 
					dif_tmp0 = prev_tmp(a) - tmp(a); 
												
					%calculate difference 
					dif_tmp1 = prev_tmp(a) - tmp(a + 1); 
							
					if dif_tmp0 > dif_tmp1
					
						%create new tmp matrix that will have the corrections to allow for Delta value calculations 
						deltacurrent(a) = tmp(a); 
					
					else 
										
						%create new tmp matrix that will have the corrections to allow for Delta value calculations 
						deltacurrent(a) = tmp(a + 1); 
						
						%saving the new cars that don't match up into new cars matrix 
						newcars(a) = tmp(a); 
						
					endif
						
				end 
			
			else 
			
			%set current tmp value to equal delta current to keep nomenclature the same 
			deltacurrent = tmp; 
			%set S to equal length of one of the vector of coordinates
			S = St(2); 
								
			endif
		
			%now all of the vectors are lined up, delta calculations can be done 
			for x = 1:S
							
				%cell by cell delta calculation here 
				delta_tmp(x) = prev_tmp(x) - deltacurrent(x);
				
				%eventually have if statement here to evaluate if there is an anomaly 
				%if so, save the 'a' value as it will probably come back
				
			end 
			
			%if there is no movement in the entire frame
				
			if sum(delta_tmp) == 0
				%throw out the values for this matrix 
				%waste time
				wastetime = 'true';
				
				%N = strcat(V, 'delta_pos'); 
				
				%delta_pos_mean = 'placeholder';
				
				%save the matrix as a file
				%dlmwrite(N, delta_pos_mean);
			
				%delta_neg_mean = 'placeholder'; 
				
				%N = strcat(V, 'delta_neg');
				
				%save the matrix as a file
				%dlmwrite(N, delta_neg_mean);
				
			%putting final delta vector calculations to only happen if movement occurred 	
			else 
								
				%save all positive delta values in one matrix, i.e, all traffic moving in one direction 
				delta_pos_sorted = delta_tmp(delta_tmp > 0);
			
				%save all positive delta values in one matrix, i.e, all traffic moving in one direction 
				delta_neg_sorted = delta_tmp(delta_tmp < 0);
			
				%MEAN DELTA CALCULATION HERE & saving to a vector of all deltas
				delta_pos_mean = mean(delta_pos_sorted);
				%create string name for file that matrix will be saved in 
				
				%n = num2str(i) 
				
				N = strcat(V, 'delta_pos'); 
				
				%save the matrix as a file
				dlmwrite(N, delta_pos_mean);
			
				delta_neg_mean = mean(delta_neg_sorted);
				
				N = strcat(V, 'delta_neg');
				
				%save the matrix as a file
				dlmwrite(N, delta_neg_mean);
				
				%reset vectors for next run, must be done to fix length changes
				delta_tmp = [0 0];
				prev_tmp = [0 0];
				deltacurrent = [0 0];
				
			endif;
		
		endif;
	
	end;
		
	%returning back a string to make this appear to Octave as a function
	finished = 'done';
	
%this will never finish when this is turned into a live stream. 
end

	