% =========================================================================
%> @section INTRO MakeInitialGeomorphology
%>
%> - 초기 지형(초기 기반암 고도와 퇴적층 두께를 포함)을 만드는 함수
%>  - 원리
%>   - 기반암 고도:
%>    - 1) 이전에 만든 기반암 고도를 초기값으로 불러오거나 2) 임의 경사를 가진
%>      평탄면을 초기값으로 만드는 함수
%>   - 퇴적층 두께:
%>    - 1) 공간적으로 동일한 값으로 설정하거나 2) 이전에 만든 퇴적층 두께를 불러옮
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval bedrockElev      : 초기 기반암 고도
%> @retval sedimentThick    : 초기 퇴적층 두께
%> @retval Y                : 행
%> @retval X                : 열

%> @param Y                             : 외곽 경계를 제외한 Y축 크기
%> @param X                             : 외곽 경계를 제외한 X축 크기
%> @param dX                        : 셀 크기 [m]
%> @param PLANE_ANGLE               : 임의 경사 [radian]
%> @param INPUT_DIR_PATH            : 입력 파일이 저장된 폴더 경로
%> @param OUTPUT_SUBDIR_PATH        : 출력 파일을 위한 폴더의 세부 폴더 경로
%> @param INIT_BEDROCK_ELEV_FILE    : 초기 기반암 고도가 기록된 파일 이름
%> @param initSedThick              : 초기 퇴적층 두께 [m]
%> @param INIT_SED_THICK_FILE       : 초기 퇴적층 두께가 기록된 파일 이름
% =========================================================================
function [bedrockElev,sedimentThick,Y,X] = MakeInitialGeomorphology(Y,X,dX,PLANE_ANGLE,INPUT_DIR_PATH,OUTPUT_SUBDIR_PATH,INIT_BEDROCK_ELEV_FILE,initSedThick,INIT_SED_THICK_FILE)
%
% function MakeInitialGeomorphology
%

% 상수 초기화
mRows = Y + 2;
nCols = X + 2;
Y_INI = 2;
Y_MAX = Y + 1;
X_INI = 2;
X_MAX = X + 1;

% 1. INIT_BEDROCK_ELEV_FILE 변수를 확인하여, 초기 지형을 만들 것인지 확인한다.
if strcmp(INIT_BEDROCK_ELEV_FILE,'No')

    % 1) 초기 지형을 만들 경우, 임의 경사를 가진 평탄면을 만든다.
    % (1) 출력 변수 초기화
    bedrockElev = zeros(mRows,nCols);

    % (2) 임의 경사를 가진 평탄면을 만드는 함수를 실행한다.
    bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = MakeFlatAreas(Y,X,dX,PLANE_ANGLE);

    % (3) 초기 지형을 파일로 저장해둔다.
    % A. 출력 파일 이름에 현재 시각을 더한다.
    dateString = datestr(now,30);
    outputFileName = ['INIT_ELEV_',dateString,'.txt'];
    outputFileName = fullfile(OUTPUT_SUBDIR_PATH,outputFileName);
    
    % C. 출력을 위한 파일을 생성한다.
    fid = fopen(outputFileName,'w');    
    if fid == -1
        error('새로 만든 초기 지형을 저장할 파일이 생성되지 않았습니다.\n');
    end
    
    % D. 파일 첫 행에는 Y,X를 기록한다.
    fprintf(fid,'%i\n%i\n',mRows,nCols);
    
    % E. 초기 지형을 파일에 기록한다.
    fprintf(fid,'%f\n', bedrockElev);
    
    fclose(fid);

else
    % 2) 저장된 지형을 초기 지형으로 불러올 경우,
    % (1) 파일의 확장자를 확인하여 이에 따라 고도 자료를 불러옴
    relativeFilePath = fullfile(INPUT_DIR_PATH,INIT_BEDROCK_ELEV_FILE);
    fileExtentionType = INIT_BEDROCK_ELEV_FILE(end-2:end);
        
    % A. 파일의 확장자가 mat인 경우에는 load 함수를 이용하여 불러온다.
    % * 주의 : mat 파일인 경우, 초기 지형 고도 변수명은 elevation으로
    %   정의되어야 한다.
    if strcmp(fileExtentionType,'mat')
            
        tmpBedrockElev = load(relativeFilePath,'elevation');
        bedrockElev = tmpBedrockElev.elevation;
                
    % B. txt인 경우에는 ReadElevation 함수를 이용하여 불러온다.
    elseif  strcmp(fileExtentionType,'txt')

        bedrockElev = ReadElevation(relativeFilePath);
    
    end

    % (2) 저장된 지형을 초기 지형으로 불러올 경우, Y,X를 재정의한다.
    [mRows, nCols] = size(bedrockElev);
    Y = mRows - 2; X = nCols - 2;
    
    % (3) 초기 지형을 출력 디렉터리에 복사한다.
    copyfile(relativeFilePath,OUTPUT_SUBDIR_PATH);

end

% 1. INIT_SED_THICK_FILE 변수를 확인하여, 초기 퇴적층 두께를 동일한 값으로
% 설정할 것인가를 확인함
if strcmp(INIT_SED_THICK_FILE,'No')
    
    % 1) 동일하게 설정할 경우
    sedimentThick = ones(mRows,nCols) * initSedThick;
    
    % (1) 출력을 위한 파일을 만듦: 이걸 굳이 만들 필요가 있을까?
    outputFileName = fullfile(OUTPUT_SUBDIR_PATH,'initSedThick.txt');
    
    fid = fopen(outputFileName,'w');
    if fid == -1
        error('초기 퇴적층 두께를 저장할 파일이 생성되지 않았습니다.');
    end
    
    % (2) 파일 첫 행에는 Y,X를 기록함
    fprintf(fid,'%i\n%i\n',mRows,nCols);
    
    % (3) 초기 퇴적층 두께를 파일에 기록함
    fprintf(fid,'%f\n',sedimentThick);
    
    fclose(fid);
            
else
    
    % 2) 저장된 퇴적층 두께를 초기 퇴적층 두께로 불러올 경우
    relativeFilePath = fullfile(INPUT_DIR_PATH,INIT_SED_THICK_FILE);
    
    sedimentThick = ReadElevation(relativeFilePath);
    
    % 초기 퇴적층 두께를 축력 디렉토리에 복사함
    copyfile(relativeFilePath,OUTPUT_SUBDIR_PATH);
    
end   
    
end % MakeInitialGeomorphology end