% =========================================================================
%> @section INTRO MakeInitialGeomorphology
%>
%> - �ʱ� ����(�ʱ� ��ݾ� ���� ������ �β��� ����)�� ����� �Լ�
%>  - ����
%>   - ��ݾ� ��:
%>    - 1) ������ ���� ��ݾ� ���� �ʱⰪ���� �ҷ����ų� 2) ���� ��縦 ����
%>      ��ź���� �ʱⰪ���� ����� �Լ�
%>   - ������ �β�:
%>    - 1) ���������� ������ ������ �����ϰų� 2) ������ ���� ������ �β��� �ҷ���
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval bedrockElev      : �ʱ� ��ݾ� ��
%> @retval sedimentThick    : �ʱ� ������ �β�
%> @retval Y                : ��
%> @retval X                : ��

%> @param Y                             : �ܰ� ��踦 ������ Y�� ũ��
%> @param X                             : �ܰ� ��踦 ������ X�� ũ��
%> @param dX                        : �� ũ�� [m]
%> @param PLANE_ANGLE               : ���� ��� [radian]
%> @param INPUT_DIR_PATH            : �Է� ������ ����� ���� ���
%> @param OUTPUT_SUBDIR_PATH        : ��� ������ ���� ������ ���� ���� ���
%> @param INIT_BEDROCK_ELEV_FILE    : �ʱ� ��ݾ� ���� ��ϵ� ���� �̸�
%> @param initSedThick              : �ʱ� ������ �β� [m]
%> @param INIT_SED_THICK_FILE       : �ʱ� ������ �β��� ��ϵ� ���� �̸�
% =========================================================================
function [bedrockElev,sedimentThick,Y,X] = MakeInitialGeomorphology(Y,X,dX,PLANE_ANGLE,INPUT_DIR_PATH,OUTPUT_SUBDIR_PATH,INIT_BEDROCK_ELEV_FILE,initSedThick,INIT_SED_THICK_FILE)
%
% function MakeInitialGeomorphology
%

% ��� �ʱ�ȭ
mRows = Y + 2;
nCols = X + 2;
Y_INI = 2;
Y_MAX = Y + 1;
X_INI = 2;
X_MAX = X + 1;

% 1. INIT_BEDROCK_ELEV_FILE ������ Ȯ���Ͽ�, �ʱ� ������ ���� ������ Ȯ���Ѵ�.
if strcmp(INIT_BEDROCK_ELEV_FILE,'No')

    % 1) �ʱ� ������ ���� ���, ���� ��縦 ���� ��ź���� �����.
    % (1) ��� ���� �ʱ�ȭ
    bedrockElev = zeros(mRows,nCols);

    % (2) ���� ��縦 ���� ��ź���� ����� �Լ��� �����Ѵ�.
    bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = MakeFlatAreas(Y,X,dX,PLANE_ANGLE);

    % (3) �ʱ� ������ ���Ϸ� �����صд�.
    % A. ��� ���� �̸��� ���� �ð��� ���Ѵ�.
    dateString = datestr(now,30);
    outputFileName = ['INIT_ELEV_',dateString,'.txt'];
    outputFileName = fullfile(OUTPUT_SUBDIR_PATH,outputFileName);
    
    % C. ����� ���� ������ �����Ѵ�.
    fid = fopen(outputFileName,'w');    
    if fid == -1
        error('���� ���� �ʱ� ������ ������ ������ �������� �ʾҽ��ϴ�.\n');
    end
    
    % D. ���� ù �࿡�� Y,X�� ����Ѵ�.
    fprintf(fid,'%i\n%i\n',mRows,nCols);
    
    % E. �ʱ� ������ ���Ͽ� ����Ѵ�.
    fprintf(fid,'%f\n', bedrockElev);
    
    fclose(fid);

else
    % 2) ����� ������ �ʱ� �������� �ҷ��� ���,
    % (1) ������ Ȯ���ڸ� Ȯ���Ͽ� �̿� ���� �� �ڷḦ �ҷ���
    relativeFilePath = fullfile(INPUT_DIR_PATH,INIT_BEDROCK_ELEV_FILE);
    fileExtentionType = INIT_BEDROCK_ELEV_FILE(end-2:end);
        
    % A. ������ Ȯ���ڰ� mat�� ��쿡�� load �Լ��� �̿��Ͽ� �ҷ��´�.
    % * ���� : mat ������ ���, �ʱ� ���� �� �������� elevation����
    %   ���ǵǾ�� �Ѵ�.
    if strcmp(fileExtentionType,'mat')
            
        tmpBedrockElev = load(relativeFilePath,'elevation');
        bedrockElev = tmpBedrockElev.elevation;
                
    % B. txt�� ��쿡�� ReadElevation �Լ��� �̿��Ͽ� �ҷ��´�.
    elseif  strcmp(fileExtentionType,'txt')

        bedrockElev = ReadElevation(relativeFilePath);
    
    end

    % (2) ����� ������ �ʱ� �������� �ҷ��� ���, Y,X�� �������Ѵ�.
    [mRows, nCols] = size(bedrockElev);
    Y = mRows - 2; X = nCols - 2;
    
    % (3) �ʱ� ������ ��� ���͸��� �����Ѵ�.
    copyfile(relativeFilePath,OUTPUT_SUBDIR_PATH);

end

% 1. INIT_SED_THICK_FILE ������ Ȯ���Ͽ�, �ʱ� ������ �β��� ������ ������
% ������ ���ΰ��� Ȯ����
if strcmp(INIT_SED_THICK_FILE,'No')
    
    % 1) �����ϰ� ������ ���
    sedimentThick = ones(mRows,nCols) * initSedThick;
    
    % (1) ����� ���� ������ ����: �̰� ���� ���� �ʿ䰡 ������?
    outputFileName = fullfile(OUTPUT_SUBDIR_PATH,'initSedThick.txt');
    
    fid = fopen(outputFileName,'w');
    if fid == -1
        error('�ʱ� ������ �β��� ������ ������ �������� �ʾҽ��ϴ�.');
    end
    
    % (2) ���� ù �࿡�� Y,X�� �����
    fprintf(fid,'%i\n%i\n',mRows,nCols);
    
    % (3) �ʱ� ������ �β��� ���Ͽ� �����
    fprintf(fid,'%f\n',sedimentThick);
    
    fclose(fid);
            
else
    
    % 2) ����� ������ �β��� �ʱ� ������ �β��� �ҷ��� ���
    relativeFilePath = fullfile(INPUT_DIR_PATH,INIT_SED_THICK_FILE);
    
    sedimentThick = ReadElevation(relativeFilePath);
    
    % �ʱ� ������ �β��� ��� ���丮�� ������
    copyfile(relativeFilePath,OUTPUT_SUBDIR_PATH);
    
end   
    
end % MakeInitialGeomorphology end