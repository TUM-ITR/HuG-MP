function [Data] = LabviewDataOpen(path,FileNames,rows,type)
        
% open all files and put in Data cell array
for i = 1:length(FileNames)
    oldFolder = cd(path);
    fid = fopen(FileNames{i},'r','s'); 
    data = fread(fid, [rows inf],type);
    fclose(fid);
    cd(oldFolder);

    % Name Variables
    Data{1,i}.Count = data(1,:);
    Data{1,i}.Time = data(1,:)*0.01;
   
    Data{1,i}.ActualTorque(1,:) = data(2,:); % SAA (Nm)
    Data{1,i}.ActualTorque(2,:) = data(3,:); % SFE
    Data{1,i}.ActualTorque(3,:) = data(4,:); % SIE
    Data{1,i}.ActualTorque(4,:) = data(5,:); % EFE

    Data{1,i}.DesiredTorque(1,:) = data(6,:); % SAA (Nm)
    Data{1,i}.DesiredTorque(2,:) = data(7,:); % SFE
    Data{1,i}.DesiredTorque(3,:) = data(8,:); % SIE
    Data{1,i}.DesiredTorque(4,:) = data(9,:); % EFE

    Data{1,i}.JointAngle(1,:) = data(10,:); % SAA (deg)
    Data{1,i}.JointAngle(2,:) = data(11,:); % SFE
    Data{1,i}.JointAngle(3,:) = data(12,:); % SIE
    Data{1,i}.JointAngle(4,:) = data(13,:); % EFE

    Data{1,i}.DesiredPosition(1,:) = data(14,:); % SAA (deg)
    Data{1,i}.DesiredPosition(2,:) = data(15,:); % SFE
    Data{1,i}.DesiredPosition(3,:) = data(16,:); % SIE
    Data{1,i}.DesiredPosition(4,:) = data(17,:); % EFE

    Data{1,i}.GravityTorque(1,:) = data(18,:); % SAA Biomedical Reference (Nm) 
    Data{1,i}.GravityTorque(2,:) = data(19,:); % SFE
    Data{1,i}.GravityTorque(3,:) = data(20,:); % SIE
    Data{1,i}.GravityTorque(4,:) = data(21,:); % EFE

    Data{1,i}.ArmGravityTorque(1,:) = data(22,:); % SAA (Nm)
    Data{1,i}.ArmGravityTorque(2,:) = data(23,:); % SFE
    Data{1,i}.ArmGravityTorque(3,:) = data(24,:); % SIE
    Data{1,i}.ArmGravityTorque(4,:) = data(25,:); % EFE

    Data{1,i}.ShoulderGravityPerc(1,:) = data(26,:); % SAA SFE SIE (%)
    Data{1,i}.ElbowGravityPerc(1,:) = data(27,:); % EFE

    Data{1,i}.PDoFVertical = data(33,:); % (mm)
    Data{1,i}.PDoFHorizontalH = data(34,:); % (deg)
    Data{1,i}.PDoFHorizontalM = data(35,:); % 
    Data{1,i}.PDoFHorizontalL = data(36,:); % 

    Data{1,i}.JointVelocity(1,:) = data(37,:); % SAA (deg/s)
    Data{1,i}.JointVelocity(2,:) = data(38,:); % SFE
    Data{1,i}.JointVelocity(3,:) = data(39,:); % SIE
    Data{1,i}.JointVelocity(4,:) = data(40,:); % EFE

    Data{1,i}.CurrentTarget(1,:)        = data(47,:); % (#)
    Data{1,i}.TransparencyRepetitions(1,:)   = data(48,:); % (#)
    Data{1,i}.TargetFlag(1,:)           = data(49,:); % (bool)
    Data{1,i}.CurrentGameRep(1,:)       = data(51,:); % (#)
    Data{1,i}.TrajectorySelector(1,:)      = data(55,:); % (#)
end

end