% in:          the 4D matrix (height, width, channels, frames) representing
%              original video
% time_offset: the time offset (in ms) between each segmentation of the output
% frame_rate:  video frame rate (fps) 
function out = rolling_shutter(in, time_offset, frame_rate)
    fprintf('%s\n', 'Building a rolling shutter effect: 0');
    out = zeros(size(in));
    next_percent_print = 0;
    percent_offset = 1;
    
    % find a new output frame for each frame
    for f=1:size(in, 4)
        % percent printout
        p = round(100 * f/size(in, 4));
        if next_percent_print <= p
            fprintf('\b');
            if next_percent_print > 9
                fprintf('\b')
            end
            fprintf('%d', next_percent_print);
            next_percent_print = next_percent_print + percent_offset;
        end
        
        % init
        new_frame = zeros(size(in, 1), size(in, 2), size(in, 3));

        % from top to bottom, calculate new rows
        for r=1:size(in, 1)
            frame_offset = get_frame_offset(r, time_offset, frame_rate);
            tw_frame = get_frame(in, f, frame_offset);
            new_frame(r, :, :) = tw_frame(r, :, :);
        end
        % save it
        out(:, :, :, f) = new_frame;
    end
    fprintf('\n%s\n', 'Rolling shutter done.');
end

% mov:   the movie data (4D matrix)
% frame: the frame we're currently building
function the_frame = get_frame(mov, frame, frame_offset)
    the_frame = mov(:, :, :, max([(frame - frame_offset) 1]));
end

% n:           the degree of the segmentation (1 for first, 2 for second..)
% time_offset: the time offset (in ms) between segmentations
% frame_rate:  the frame rate (fps) of the video
function frame_offset = get_frame_offset(n, time_offset, frame_rate)
    delay = n * time_offset;
    time_between_frames = 1000 / frame_rate; % ms
    frame_offset = round(delay / time_between_frames);
end