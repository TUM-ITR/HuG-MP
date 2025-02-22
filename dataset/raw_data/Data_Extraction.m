clear
close all
clc

%% Define File to Open
% open files
variables_type = 'single';
rows_in_labview_file = 61;

Path = 'S07';                                       % select subject
PatientStr = '\*Transparency_Test*.bin';                   % select the transparency/task (it then opens all the files associated with that task)

listFile = dir(strcat(Path,PatientStr));
for iii = 1: length(listFile)
    FileNames(1,1).N{iii} = listFile(iii).name;
end
Dataset = LabviewDataOpen(Path,FileNames(1,1).N,rows_in_labview_file,variables_type);

jnts_trajs = Dataset{1}.JointAngle;
time = Dataset{1}.Time - Dataset{1}.Time(1);
Vert_PDoF = Dataset{1}.PDoFVertical;
% selected_pnt_i = peak_select(time,jnts_trajs(4,:),'manual');
figure
plot(time,Vert_PDoF)
figure
for i = 1:4  
    
    subplot(2,2,i)
    plot(time,jnts_trajs(i,:))
    
    xlim([time(1) time(end)])
    grid on

end

n_tasks = 6;
n_subtasks = [6,6,6,8,2,2];
read_cursor = 0;
tasks = cell(10,n_tasks);

% Dataset{1,1}.TransparencyRepetitions(11227) = 11;

for i = 1:n_tasks

    % Specific of a given individual: done to delete wrong trials!!!
    % if i == 1 || i == 4 
    %     set = [1:4,6:11];
    % else
    %     set = 1:10;
    % end
    set = 1:10;


    for j = set
        
        segments = cell(n_subtasks(i),1);

        idx_init = find(Dataset{1}.TransparencyRepetitions(read_cursor+1:end) == j,1);
        idx_end = find(Dataset{1}.TransparencyRepetitions(read_cursor+1:end) == j + 1,1);
        jnts_data_section = Dataset{1}.JointAngle(:,read_cursor+idx_init : read_cursor+idx_end-1);
        read_cursor = read_cursor + idx_end;
        
        n_i_j = size(jnts_data_section,2);
        jnts_i_j_dot = zeros(4,n_i_j);
        time_sec = (0:n_i_j - 1) * 0.01;

        figure(4)
        for b = 1:4
            jnts_i_j_dot(b,:) = Nderive(jnts_data_section(b,:),0.01);
            subplot(2,2,b); 
            plot(time_sec,jnts_data_section(b,:))
            % plot(time_sec,jnts_i_j_dot(b,:))
        end
        % figure
        % plot(time_sec, sum(abs(jnts_i_j_dot),1) )
        min_dist = 1.6;
        figure(1)
        findpeaks( sum(abs(jnts_i_j_dot),1) , 1 / 0.01 ,'MinPeakDistance',min_dist,'SortStr','descend','NPeaks',n_subtasks(i))
        
        
        [peaks, idx_peaks] = findpeaks( sum(abs(jnts_i_j_dot),1) , 1 / 0.01 ,'MinPeakDistance',min_dist,'SortStr','descend','NPeaks',n_subtasks(i));
        prompt = "Is it okay? (y/n; a if a part is missing from the end; p if a part is missing from the start): ";
        a = input(prompt,"s");
        
        if strcmp(a,"a") == 1
            jnts_data_section = Dataset{1}.JointAngle(:,read_cursor - idx_end +idx_init : read_cursor - 1 + 100);
            n_i_j = size(jnts_data_section,2);
            jnts_i_j_dot = zeros(4,n_i_j);
            time_sec = (0:n_i_j - 1) * 0.01;
            for b = 1:4
            jnts_i_j_dot(b,:) = Nderive(jnts_data_section(b,:),0.01);
            end
            
        elseif strcmp(a,"p") == 1
            jnts_data_section = Dataset{1}.JointAngle(:,read_cursor - idx_end +idx_init - 100 : read_cursor-1);
            n_i_j = size(jnts_data_section,2);
            jnts_i_j_dot = zeros(4,n_i_j);
            time_sec = (0:n_i_j - 1) * 0.01;
            for b = 1:4
            jnts_i_j_dot(b,:) = Nderive(jnts_data_section(b,:),0.01);
            end
        end

        if strcmp(a,"y") == 0
            smth = peak_select(time_sec',sum(abs(jnts_i_j_dot),1)','manual');
            idx_peaks = smth.indx;
        else
            idx_peaks = round(sort(idx_peaks,'ascend') * 100);
        end
        
        sum_abs_dot = sum(abs(jnts_i_j_dot),1);

        for k = 1:n_subtasks(i)

            threshold = 4;

            if k == 1
                idx_prev = find( fliplr(sum_abs_dot(1:idx_peaks(k)-1)) < threshold, 1);
                idx_aft = find( sum_abs_dot(idx_peaks(k)+1:idx_peaks(k+1)) < threshold, 1);
                if isempty(idx_aft) == 1
                    [~, idx_aft] = min(sum_abs_dot(idx_peaks(k)+1:idx_peaks(k+1)));
                end
                if isempty(idx_prev) == 1
                    [~, idx_prev] = min( fliplr(sum_abs_dot(1:idx_peaks(k)-1)) );
                end
            elseif k == n_subtasks(i)
                idx_prev = find( fliplr(sum_abs_dot(idx_peaks(k-1):idx_peaks(k)-1)) < threshold, 1);
                idx_aft = find( sum_abs_dot(idx_peaks(k)+1:end) < threshold, 1);
                if isempty(idx_prev) == 1
                    [~, idx_prev] = min( fliplr(sum_abs_dot(idx_peaks(k-1):idx_peaks(k)-1)) );
                end
                if isempty(idx_aft) == 1
                    [~, idx_aft] = min( sum_abs_dot(idx_peaks(k)+1:end) );
                end
            else
                idx_prev = find( fliplr(sum_abs_dot(idx_peaks(k-1):idx_peaks(k)-1)) < threshold, 1);
                idx_aft = find( sum_abs_dot(idx_peaks(k)+1:idx_peaks(k+1)) < threshold, 1);
                if isempty(idx_aft) == 1
                    [~, idx_aft] = min(sum_abs_dot(idx_peaks(k)+1:idx_peaks(k+1)));
                end
                if isempty(idx_prev) == 1
                    [~, idx_prev] = min( fliplr(sum_abs_dot(idx_peaks(k-1):idx_peaks(k)-1)) );
                end
            end

            section_idx = idx_peaks(k) - idx_prev : idx_peaks(k) + idx_aft ;
            if isempty(section_idx) == 1
                error('Curve not acquired')
            end
            % figure
            % plot(sum_abs_dot(section_idx));
            segments{k} = jnts_data_section(:,section_idx);
 
        end

        tasks{j,i} = segments;

     
    end
end

% save(strcat(Path,"_trajs"),"tasks");
