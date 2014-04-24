% =========================================================================
%> @section INTRO AnalyseResult
%>
%> AnalyseResult ����� �м��ϴ� �Լ�
%>
%> @version 0.21
%> @see AccumulateUpstreamFlow(), CalcFacetFlow(), CalcInfinitiveFlow()
%>      ,CalcSDSFlow(), DefineUpliftRateDistribution(), FindSDSDryNbr()
%>      ,IsBoundary(), IsDry(), LoadParameterValues(), ProcessSink()
%>      ,ReadParameterValue(), hypsometry(), streamorder(), wflowacc()
%>      
%>
%> @retval majorOutputs              : �ֿ� ����� ������ �ڷ�
%>
%> @param OUTPUT_SUBDIR             : ��� ������ ����� ���͸�
%> @param GRAPH_INTERVAL            : ���ǰ���� ��ϵ� ���Ͽ��� �׷����� �����ִ� ����
%> @param startedTimeStepNo         : �׷��� ��� ����
%> @param achievedRatio             : �� ���ǱⰣ�� ����� ���� �κ��� ����
%> @param EXTRACT_INTERVAL          : (�׷����� �����ִ� ����) (2����) �ֿ� ������ �����ϴ� ����
%> @param SHOW_GRAPH                : �ֿ� ����� �׷����� ������ �������� ������
%>
%>
%> * �м�����
%>  01. 3���� DEM
%>  02. �����
%>  03. ������ �β�
%>  04. ���
%>  05. ǳȭ��
%>  06. ����ۿ뿡 ���� ������ �β� ��ȭ��
%>  07. ���� ����ۿ뿡 ���� ������ �β� ��ȭ��
%>  08. ���� ����ۿ뿡 ���� ��ݾ� �� ��ȭ��
%>  09. flooded region ����
%>  10. ��������
%>  11. ��õ�ۿ뿡 ���� ������ �β� ��ȭ��
%>  12. ��õ�ۿ뿡 ���� ��ݾ� �� ��ȭ��
%>  13. �������ȯ�� �з�
%>  14. ���� ħ�ķ�
%>  15. TPI
%>  16. ������ �������� �м��� (����� ��)
%>  17. Ⱦ�ܰ�� �Ӽ� (AnalyseFinalResult �Լ� �Էº���)
%>      : ��� ������ ��� �β�, ��õ ������ ��� �β�, ����ۿ뿡 ���� ������
%>        �β� ��ȭ��, ��õ�� ���� ������ �β� ��ȭ��, ������, ǳȭ��
%>  18. ��õ���ܰ �Ӽ�
%>      : ��ݾ� �ϻ� ��, ��ݾ� �ϻ� + ������ ��� �β�
%>  19. �������� Ư��
%>      : ��հ�, ��հ��, ��� ǳȭ��, �ϰ�е�, ���ȯ����� ..
%>  20. ������ ���� ���� ��� ħ�ķ��� ������
%>      : ħ������ ������
%>  21. ������ ����
%>      : ���� (���) ������ ����, �ϵ� �� �ϻ� ������ ����
%>  22. �ϰ���� (����������) ��õ����
%>  23. ���Ҹ�Ʈ�� �
%>
%> * ����:
%>  - EXTRACT_INTERVAL
%>    : GRAPH_INTERVAL�� ���ų� ���� ����� ��
%>    : �ֿ� 1���� ������ �׷����� �����ִ� ���ݰ� �����ϰ� ������
%>  - SHOW_GRAPH
%>    : 1: �׷����� ������
%>    : 2: �׷����� �������� ����
%>
%> * History
%>  - 2011/10/27
%>   - �������ȯ�� �׷��� �˰��� ������
%>  - 2011/10/06
%>   - �ּ����� ���� �� ����ȭc
%>  - 2010/09/28
%>   - ������ ���ǰ���� �����ؼ� �� �� �ֵ��� ������
%>   - �ֿ� ���� ������
%>   - ���� ���������ۿ뿡 ���� ����ȭ�� �ֱ� �� ������ �β� �� ��ݾ� ���� �̿���
%>
% =========================================================================
function majorOutputs = AnalyseResult(OUTPUT_SUBDIR,PARAMETER_VALUES_FILE,GRAPH_INTERVAL,startedTimeStepNo,achievedRatio,EXTRACT_INTERVAL,SHOW_GRAPH)
%
% function Analyse2DResult
%

%==========================================================================
% 1. ��� �� ���� �ʱ�ȭ
% * ����: GPSSMain() ���ۺκа� ������. ���� GPSSMain()���� �������� ��.
% * ������ �κ�
%   : ������� ��� ����
%   : �߿��� �ʱ� ������ �Է�
%   : ������ϰ�� ��� ����
%   : �� ������� ����
%   : �׿� ��� �� ���� �ʱ�ȭ
%   : ���ǱⰣ���� �������� ��,���� ���� ����
% * �ٸ� �κ�
%   : �Էº��� ����
%   : ��� ���͸��� �ִ� parameterValues.txt�� �ҷ���
%   : INPUT_FILE_PARAM_PATH = fullfile(INPUT_DIR_PATH,parameterValuesFile); ������
%   : ��������� read ���� ��
%   : MakeInitialGeomorphology() ������
%   : mRows, nCols�� FID_LOG ������ ���� �ҷ���

% 1) ���ǰ�� ������ϵ��� �ϴ� ����ΰ� �������� �ʱ⺯�� �Է°��� ����
%--------------------------------------------------------------------------
% GPSSMain()�� �ٸ� �κ�
%--------------------------------------------------------------------------

% �Էº��� ����
if mod(GRAPH_INTERVAL,EXTRACT_INTERVAL) ~= 0
    error('�ֿ� 2���� ������ �����ϴ� ������ �׷����� �����ִ� ������ ������� �մϴ�.');    
end

% ��� ���͸��� �ִ� parameterValues.txt �� ������
DATA_DIR = 'data';      % ����� ������ �����ϴ� �ֻ��� ���͸�
OUTPUT_DIR = 'output';  % ��� ������ ������ ���͸�
parameterValuesFile = PARAMETER_VALUES_FILE;    % �ʱ� �Է°� ����
OUTPUT_DIR_PATH = fullfile(DATA_DIR,OUTPUT_DIR);
INPUT_FILE_PARAM_PATH ... % �Է� ���� ��� ���
    = fullfile(OUTPUT_DIR_PATH,OUTPUT_SUBDIR,parameterValuesFile);

%--------------------------------------------------------------------------
% GPSSMain()�� ���� �κ�
%--------------------------------------------------------------------------

% ��� ���� ��� : ���� ����� ����ϴ� ����
OUTPUT_FILE_SEDTHICK ...                % i��° ������ �β� [m]
    = 'sedThick.txt';
OUTPUT_FILE_BEDROCKELEV ...             % i��° ��ݾ� �� [m]
    = 'bedrockElev.txt';
OUTPUT_FILE_WEATHER ...                 % ǳȭ�� [m/dT]
    = 'weatherProduct.txt';
OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE ...   % ����ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
    = 'dSedThickByHillslope.txt';
OUTPUT_FILE_CHANBEDSEDBUDGET ...        % ����ۿ뿡 ���� �ϵ� ������κ��� �ϵ����� ������ [m^3/m^2 dT]
    = 'chanBedSedBudget.txt';
OUTPUT_FILE_dSEDTHICK_BYFLUVIAL ...     % ��õ�ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
    = 'dSedThickByFluvial.txt';
OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL ...  % ��õ�ۿ뿡 ���� ��ݾ� �� ��ȭ�� [m^3/m^2 dT]
    = 'dBedrockElevByFluvial.txt';
OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS ...   % ���� �Ž������Ʈ�� ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
    = 'dSedThickByRapidMassmove.txt';
OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS ... % ���� �Ž������Ʈ�� ���� ��ݾ� �� ��ȭ�� [m^3/m^2 dT]
    = 'dBedrockElevByRapidMassmove.txt';
OUTPUT_FILE_LOG ...                     % GPSSMain() ���� ������ ��Ȳ ���
    = 'log.txt';

% �߿��� �ʱ� �������� �Է���
%--------------------------------------------------------------------------
% GPSSMain()�� �ٸ� �κ�
% : INPUT_FILE_PARAM_PATH = fullfile(INPUT_DIR_PATH,parameterValuesFile); ������
%--------------------------------------------------------------------------
[OUTPUT_SUBDIR ...          % ��� ������ ������ ���� ���͸�
,Y ...                      % (�ʱ� ������ ���� ���) �ܰ� ��踦 ������ Y�� ũ��
,X ...                      % (�ʱ� ������ ���� ���) �ܰ� ��踦 ������ X�� ũ��
,dX ...                     % �� ũ��
,PLANE_ANGLE ...            % (�ʱ� ������ ���� ���) ��ź���� ��� [m/m]
,INIT_BEDROCK_ELEV_FILE ... % (�ʱ� ������ �ҷ��� ���) �ʱ� ������ ������ ����
,initSedThick ...           % �ʱ� ������ �β� [m]
,INIT_SED_THICK_FILE ...    % �ʱ� ������ ������ �β��� �ҷ��� ��� �̸� ������ ����
,TIME_STEPS_NO ...          % �� ���� Ƚ��
,INIT_TIME_STEP_NO ...      % ���� ���� ������� �̾ �� ����� �ʱ� ���� Ƚ��
,dT ...                     % TIME_STEPS_NO�� ���̱� ���� �������� �����Ⱓ [yr]
,WRITE_INTERVAL ...         % ���� ����� ����ϴ� �� ����
,BOUNDARY_OUTFLOW_COND ...  % �� �������κ��� ������ �߻��ϴ� ���ⱸ �Ǵ� ��踦 ����
,TOP_BOUNDARY_ELEV_COND ...     % �� �ܰ� ��� �� ����
,IS_LEFT_RIGHT_CONNECTED ...    % �¿� �ܰ� ��� ������ ����
,TOTAL_ACCUMULATED_UPLIFT ...   % ���� �Ⱓ ���� �� ���� ���ⷮ [m]
,IS_TILTED_UPWARPING ...        % �浿�� ��� �������� ��� ����
,UPLIFT_AXIS_DISTANCE_FROM_COAST ...    % �ؾȼ����κ��� ����������� �Ÿ� [m]
,RAMP_ANGLE_TO_TOP ...          % (���� ���� ���ⷮ�� ����) �����࿡�� �� ������ ��
,Y_TOP_BND_FINAL_ELEV ...       % �� ����� ���� ��
,UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND ... % �������� �ð��� ���� ����
,acceleratedUpliftPhaseNo ...   % (������ ��������) ���ǱⰣ ���� ���� �������� �߻��ϴ� ��
,dUpliftRate ...            % (������ ��������) ��� ���� �������� �������� �ִ� �ּ� �������� ���� ����
,upliftRate0 ...            % (������ ��������) ������ ��������� �ʱ� ������ [m/yr]
,waveArrivalTime ...        % (�浿�� ��� �������� ����) ���� �ܰ� ��� ���� ���������� �ϰ��ϴ� ���� (���� �Ⱓ���� ����)
,initUpliftRate ...         % (�浿�� ��� �������� ����) ������ �ϰ� ���� ħ�� ���ظ� �ϰ��� [m/yr]
,kw0 ...                    % ���� ǳȭ�Լ����� ����Ǵ� ���� ��ݾ��� ǳȭ�� [m/yr]
,kwa ...                    % ���� ǳȭ�Լ��� ������
,kw1 ...                    % ���� ���� ǳȭ�Լ����� ����Ǵ� ���� ��ݾ��� ǳȭ�� [m/yr]
,kwm ...                    % ǳȭ�� �β� ���� [m]
,kmd ...                    % ����ۿ��� Ȯ�� ���
,soilCriticalSlopeForFailure ... % õ��Ȱ���� ���� ��鰢
,rockCriticalSlopeForFailure ... % ��ݾ�Ȱ���� ���� ��鰢
,annualPrecipitation ...    % �� ���췮 [m/yr]
,annualEvapotranspiration ... % �� ���߻귮 [m/yr]
,kqb ...                    % ��������� ������������ ����Ŀ��� ���
,mqb ...                    % ��������� ������������ ����Ŀ��� ����
,bankfullTime ...           % �������� ���� �Ⱓ [s]
,timeWeight ...             % �������� ���ӱⰣ�� ���̱� ���� ħ���� ����ġ
,minSubDT ...               % �ּ����� ���δ��� �ð� [s]
,khw ...                    % ���������� �������� ����Ŀ��� ���
,mhw ...                    % ���������� �������� ����Ŀ��� ����
,khd ...                    % ���������� ���ɰ��� ����Ŀ��� ���
,mhd ...                    % ���������� ���ɰ��� ����Ŀ��� ����
,FLUVIALPROCESS_COND ...    % flooded region�� �� ������ �β� ��ȭ���� �����ϴ� ���
,channelInitiation ...      % ��õ ���� ���� �Ӱ谪
,criticalUpslopeCellsNo ... % ��õ ���� �Ӱ� ������� �� ����
,mfa ...                    % ��õ�� ���� ������ ����� ���Ŀ��� ������ ����
,nfa ...                    % ��õ�� ���� ������ ����� ���Ŀ��� ����� ����
,fSRho ...                  % ��ݵǴ� �������� ��� �е�
,fSD50 ...                  % ��ݵǴ� �������� �߰� �԰�
,eta ...                    % ��ݵǴ� �������� ��� ������
,nA ...                     % ���� ��õ �ϵ������� Manning ���� ���
,mfb ...                    % ��ݾ� �ϻ� ħ���� ���Ŀ��� ������ ����
,nfb ...                    % ��ݾ� �ϻ� ħ���� ���Ŀ��� ����� ����
,kfbre ...                  % ��ݾ� �ϻ� ���൵
,nB] ...                    % ��ݾ� �ϻ� �ϵ������� Manning ���� ���
    = LoadParameterValues(INPUT_FILE_PARAM_PATH);

% -------------------------------------------------------------------------
% ���� LoadParameterValues �Լ��� ���Ե� �ʱ� �Է°�

% 1. �ݺ��� �� �ӽ� ���� �����ð� ������ ���õ� ������ ����� ����
% (����ȭ�� ���� �ľ��ϱ� ����� ���⼭ �ϴ� ������)
basicManipulationRatio = 0.5; nt = 4;

%--------------------------------------------------------------------------

% ���� ����� �����ϴ� ���� ���͸�
mkdir(OUTPUT_DIR_PATH,OUTPUT_SUBDIR);
OUTPUT_SUBDIR_PATH = fullfile(OUTPUT_DIR_PATH,OUTPUT_SUBDIR);

% ��� ���� ��� ���
OUTPUT_FILE_WEATHER_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_WEATHER);
OUTPUT_FILE_SEDTHICK_PATH ...`
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_SEDTHICK);
OUTPUT_FILE_BEDROCKELEV_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_BEDROCKELEV);
OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE);
OUTPUT_FILE_CHANBEDSEDBUDGET_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_CHANBEDSEDBUDGET);
OUTPUT_FILE_dSEDTHICK_BYFLUVIAL_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dSEDTHICK_BYFLUVIAL);
OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL);
OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS);
OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS);
OUTPUT_FILE_LOG_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_LOG);

%--------------------------------------------------------------------------
% GPSSMain()�� �ٸ� �κ�
% : read ���� ������ ��
% : MakeInitialGeomorphology()�� ������
% : mRows,nCols�� FID_LOG�� ���� ������
%--------------------------------------------------------------------------

% ���� ������ �����: read ���� ������ ��
FID_SEDTHICK = fopen(OUTPUT_FILE_SEDTHICK_PATH,'r');
FID_BEDROCKELEV = fopen(OUTPUT_FILE_BEDROCKELEV_PATH,'r');
FID_WEATHER = fopen(OUTPUT_FILE_WEATHER_PATH,'r');
FID_dSEDTHICK_BYHILLSLOPE = fopen(OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE_PATH,'r');
FID_CHANBEDSEDBUDGET = fopen(OUTPUT_FILE_CHANBEDSEDBUDGET_PATH,'r');
FID_dSEDTHICK_BYFLUVIAL = fopen(OUTPUT_FILE_dSEDTHICK_BYFLUVIAL_PATH,'r');
FID_dBEDROCKELEV_BYFLUVIAL = fopen(OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL_PATH,'r');
FID_dSEDTHICK_BYRAPIDMASS = fopen(OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS_PATH,'r');
FID_dBEDROCKELEV_BYRAPIDMASS = fopen(OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS_PATH,'r');
FID_LOG = fopen(OUTPUT_FILE_LOG_PATH,'r');

% MakeInitialGeomorphology�� ������

% mRows,nCols�� FID_LOG ������ ���� ����
mRows ... % �� (�ܰ� ��� ����) ���� �� ����
    = fscanf(FID_LOG,'%i',1);
nCols ... % �� (�ܰ� ��� ����) ���� �� ����
    = fscanf(FID_LOG,'%i',1);

%--------------------------------------------------------------------------
% GPSSMain()�� ���� �κ�
%--------------------------------------------------------------------------

% ��� �� ���� �ʱ�ȭ
Y_TOP_BND = 1;          % �� �ܰ� �� ��� Y ��ǥ��
Y_BOTTOM_BND = mRows;   % �� �ܰ� �Ʒ� ��� Y ��ǥ��
Y_INI = 2;              % �� ���� Y ���� ��ǥ��
Y_MAX = Y+1;            % �� ���� Y ������ ��ǥ��

X_LEFT_BND = 1;         % �� �ܰ� �� ��� X ��ǥ��
X_RIGHT_BND = nCols;    % �� �ܰ� �� ��� X ��ǥ��
X_INI = 2;              % �� ���� X ���� ��ǥ��
X_MAX = X+1;            % �� ���� X ������ ��ǥ��

OUTER_BOUNDARY = true(mRows,nCols); % �� ���� �ܰ� ���
OUTER_BOUNDARY(Y_INI:Y_MAX,X_INI:X_MAX) = false;

CELL_AREA = dX * dX; % �� ����

QUARTER_PI = 0.785398163397448;     % pi * 0.25
HALF_PI = 1.57079632679490;         % pi * 0.5
ROOT2 = 1.41421356237310;           % sqrt(2)

DISTANCE_RATIO_TO_NBR = [1 ROOT2 1 ROOT2 1 ROOT2 1 ROOT2];

[arrayX ...             % �� (�ܰ� ��� ����) ���� X ��ǥ ���
,arrayY] ...            % �� (�ܰ� ��� ����) ���� Y ��ǥ ���
    = meshgrid(X_LEFT_BND:X_RIGHT_BND,Y_TOP_BND:Y_BOTTOM_BND);

% * ���� : ���λ� 's'�� (mRows*mCols) ���� ���� Y*X ũ�⸦ ������ ���
[sArrayX ...            % �� (�ܰ� ��� ����) ���� X ��ǥ ���
,sArrayY] ...            % �� (�ܰ� ��� ����) ���� Y ��ǥ ���
    = meshgrid(X_INI:X_MAX,Y_INI:Y_MAX);

% (���� ������ ���ϴ� ��������) facet�� �����ϴ� �߾� ��(e0) ���� ���
e0LinearIndicies ...
    = (arrayX-1) * mRows + arrayY;
% * ����: �¿� �ܰ� ��谡 ����Ǿ��ٸ�, �¿� �ܰ� ��� ������ ������
if IS_LEFT_RIGHT_CONNECTED == true
    e0LinearIndicies(:,X_LEFT_BND) = e0LinearIndicies(:,X_MAX);
    e0LinearIndicies(:,X_RIGHT_BND) = e0LinearIndicies(:,X_INI);    
end
sE0LinearIndicies = (sArrayX-1) * mRows + sArrayY;

% (�ִ��Ϻΰ�� ������ ���ϴ� ��������) 8 ���� �̿� ���� ����Ű�� 3���� ���� �迭
s3IthNbrLinearIndicies = zeros(Y,X,8);

% * ����: ������ ���ʿ���  �� �ð� ����.
ithNbrYOffset ... % �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� Y�� �ɼ�
    = [0 -1 -1 -1  0  1  1  1];
ithNbrXOffset ... % �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� X�� �ɼ�
    = [1  1  0 -1 -1 -1  0  1];

% facet�� �����ϴ� e1�� e2�� ���� �迭 ����
s3E1LinearIndicies = zeros(Y,X,8);
s3E2LinearIndicies = zeros(Y,X,8);

% * ����: �� �ð� ������ ���� �ƴ�. Tarboton(1997)�� Figure 2�� Table 1 ����
ithFacetE1Offset ... % e0�κ��� facet�� �����ϴ� e1�� ����Ű�� ���� �ɼ�
    = [ mRows   -1       -1       -mRows   ...
       -mRows    1        1        mRows  ];
ithFacetE2Offset ... % e0�κ��� facet�� �����ϴ� e2�� ����Ű�� ���� �ɼ�
    = [ mRows-1  mRows-1 -mRows-1 -mRows-1 ...
       -mRows+1 -mRows+1  mRows+1  mRows+1];

% 8 ���� �̿� ���� ���� �� 8 ���� facet�� e1, e2 ����
for ithDir = 1:8
    
    % (���ʿ��� �� �ð� ��������)
    s3IthNbrLinearIndicies(:,:,ithDir) ...  % �� ������ �̿� �� ����
        = e0LinearIndicies(sE0LinearIndicies ...
        + (ithNbrXOffset(ithDir) * mRows + ithNbrYOffset(ithDir)));

    % (���ʿ��� �� �ð� �������� )
    s3E1LinearIndicies(:,:,ithDir) ...  % �� facet�� e1 ����
        = e0LinearIndicies(sE0LinearIndicies + ithFacetE1Offset(ithDir));
    s3E2LinearIndicies(:,:,ithDir) ...  % �� facet�� e2 ����
        = e0LinearIndicies(sE0LinearIndicies + ithFacetE2Offset(ithDir));

end

vectorY = reshape(sArrayY,[],1); % Y ��ǥ ����� ����
vectorX = reshape(sArrayX,[],1); % X ��ǥ ����� ����

SECPERYEAR = 31536000;          % = 365 * 24 * 60 * 60
FLOODED = 2;                    % flooded region �±�

dTAfterLastShallowLandslide = zeros(mRows,nCols); % ������ õ��Ȱ�� ���� ��� �ð�
dTAfterLastBedrockLandslide = zeros(mRows,nCols); % ������ ��ݾ�Ȱ�� ���� ��� �ð�

% oldChanBedSed ...               % ���� �ϵ� �� �ϻ� ������ [m^3]
%     = zeros(mRows,nCols);    
% dChanBedSedPerDT ...            % ���� �ϵ� �� �ϻ� ���������� ���� [m^3/dT]
%     = zeros(mRows,nCols);
chanBedSedBudgetPerDT ...       % ���� �ϻ� �������� ���� ���� ���������� ���� [m^3/dT]
    = zeros(mRows,nCols);
remnantChanBedSed ...           % ���� �ϻ� ������ [m^3]
    = zeros(mRows,nCols);

%--------------------------------------------------------------------------
% ���� ��õ�� ���� ������ ����� ����(Einstein-Brown)�� ���

% * ����: Hortonian Overlandflow�� �����Ͽ�����, �ٸ� ���� ȯ���� ÷���� ����
annualRunoff ...        % ���� ��ǥ ���ⷮ[m/year]
    = annualPrecipitation - annualEvapotranspiration;

g = 9.8;                % �߷� ���ӵ� [m/s^2]
nu = 1.47 * 10^(-6);    % ������ ���� ������ (kinematic viscosity) [m^2/s]
wGamma = 1000;          % �� ���� [kgf/m^3]
wRho = 1000;            % �� �е� [kg/m^3]
fSGamma = fSRho;        % ������ ���� [kgf/m^3]
s = fSGamma / wGamma;   % ������ ��� �е� []
F ...                   % ������ �縳�� ħ�� �ӵ� (Brown(1950),Yang(2003))
    = (2/3 + (36 * nu^2) / (g * fSD50^3 * (s-1)))^0.5 ...
     - ((36 * nu^2) / (g * fSD50^3 * (s-1)))^0.5;
kfa ...                 % ������ ����� ���� ��� 
    = (1 / (fSGamma * (1 - eta))) ... % [kg/m s] -> [m^2/s]
    * 40 * fSGamma * F * (g * (s-1) * fSD50^3)^0.5 ...
    * (1 / ((s-1) * fSD50))^3 * nA ^ 1.8;

%--------------------------------------------------------------------------
% ���ǱⰣ ���� �������� ������, �ð��� ������ ������

[meanUpliftRateSpatialDistribution ...  % (���ǱⰣ ���) ���� �������� ������ ����
,upliftRateTemporalDistribution ...     % (���ǱⰣ) ���� �������� �ð��� ����
,meanUpliftRateAtUpliftAxis ...         % �������� (���ǱⰣ ���) ���� ������
,topBndElev] ...                        % �ܰ� �� ��迡���� ��
    = DefineUpliftRateDistribution(Y,X,Y_INI,X_INI,Y_MAX,X_MAX,dX ...
    ,TIME_STEPS_NO,TOTAL_ACCUMULATED_UPLIFT,dT ...
    ,IS_TILTED_UPWARPING,UPLIFT_AXIS_DISTANCE_FROM_COAST ...
    ,TOP_BOUNDARY_ELEV_COND,Y_TOP_BND_FINAL_ELEV ...
    ,RAMP_ANGLE_TO_TOP ...
    ,UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND ...
    ,dUpliftRate,acceleratedUpliftPhaseNo,upliftRate0 ...
    ,waveArrivalTime,initUpliftRate);

%--------------------------------------------------------------------------
% GPSSMain()�� �ٸ� �κ�
%--------------------------------------------------------------------------

% 2) �м� figure ��ġ �� ũ�� ����

% �׷��� �����ֱ� �ɼ� ��� ����
SHOW_GRAPH_YES = 1;
SHOW_GRAPH_NO = 2;

% (1) �м��� �׷����� ������ ���, figure���� ��ġ�� �ڵ� ����
if SHOW_GRAPH == SHOW_GRAPH_YES

    % A. ����� ��ġ ���� ���� ����

    % �ָ���� ��� ����
    LEFT_MONITOR = 1;
    RIGHT_MONITOR = 2;
    
    % �ָ������ ��ġ ����
    primaryMonitor = LEFT_MONITOR;
    secondaryMonitor = RIGHT_MONITOR;
    
    % (figure ��ġ�� ����) ����� ����
    leftMonWidthDivisionNo = 6;                 % ���� ����� ���� ��:��,��
    leftMonHeightDivisionNo = 3;
    rightMonWidthDivisionNo = 6;                % ���� ����� ���� ��:��,��
    rightMonHeightDivisionNo = 3;    
    
    % figure â �� ����
    % * ����: figure ��ġ �����ÿ� â ���� ������� �ʱ� ������ �̸� ���� �β���
    %   â ���� ���� �ľ���
    figSideBorderThick = 1;
    figHeaderBorderThick = 40;
    bothThick = figSideBorderThick + figHeaderBorderThick;
    
    % B. ����� ��ġ �� ���� ���� �ľ�
    monPosition = get(0,'MonitorPosition'); % ����� ��ġ ���� ȹ��
    % * ����: ��� ������ϰ��, �ָ���Ͱ� 1° �࿡ �׸��� �θ���ʹ� 2° �࿡
    %   ���� ������ ��Ÿ��.
    %   1���� ����� ���� ù��° ȭ���� ��ġ, 2���� �Ʒ� ù��° ȭ���� ��ġ,
    %   3���� ����� �¿���, 4���� ����� ���Ʒ�����. ���� ȭ��.
    % * ����: �ָ���ʹ� 1���� 2�� ��� ���� 1�� �Էµ�. ���� �ָ���Ͱ�
    %   ������ ���� ���, ���� ������� ���� ù��° ȭ���� ��ġ�� ���� ���� ����
    %
    % * ��1: set(0,'Units','Normalized')�� ���� ���� ���
    % * ��1: �ָ���Ͱ� ����(�ػ�: 1680x1050)�̰�, �θ����(�ػ�:
    %   1024x768)�� ������ ��ġ�� ���
    %   (1025, 1, 2074, 1050; 1, 1, 1024, 768)
    % * ��2: �ָ���Ͱ� ����(�ػ�: 1024x768)�̰�, �θ����(�ػ�:
    %   1680x1050)�� ������ ��ġ�� ���
    %   (1, 1, 1680, 1050; -1023, 1, 0, 768)
    
    if primaryMonitor == LEFT_MONITOR
        
        % ���� ����� ��ġ
        leftMonLeftPos = 1;
        leftMonBottomPos = monPosition(primaryMonitor,2);   % ���� ����� �ٴ� ��ġ
        leftMonWidth = monPosition(primaryMonitor,3);       % ���� ����� �¿� ����
        leftMonHeight = monPosition(primaryMonitor,4);      % ���� ����� ���Ʒ� ����

        % ���� ����� ��ġ
        rightMonLeftPos = monPosition(secondaryMonitor,1);  % ���� ����� ���� ù��° ȭ�� ��ġ    
        rightMonBottomPos = 1;                                 % ���� ����� �ٴ�. * ����: monPosition(secondaryMonitor,2)�� �̻���
        rightMonWidth = monPosition(secondaryMonitor,3);    % ���� ����� �¿� ����
        % * ����: �ָ���Ͱ� �����̰� �θ���Ͱ� �����̸� ���� ������� �¿� ���̸�
        %   ������
        rightMonWidth = rightMonWidth - leftMonWidth;
        rightMonHeight = monPosition(secondaryMonitor,4); % ���� ����� ���Ʒ� ����
        
    else % primaryMonitor == LEFT_MONITOR
        
        % ���� ����� ��ġ
        leftMonLeftPos = monPosition(secondaryMonitor,1);       % ���� ����� ���� ù��° ȭ�� ��ġ 
        leftMonBottomPos = monPosition(secondaryMonitor,2);     % ���� ����� �ٴ� ��ġ
        leftMonWidth = - monPosition(secondaryMonitor,1);       % ���� ����� �¿� ����
        leftMonHeight = monPosition(secondaryMonitor,4) - monPosition(secondaryMonitor,2);      % ���� ����� ���Ʒ� ����

        % ���� ����� ��ġ
        rightMonLeftPos = monPosition(primaryMonitor,1);  % ���� ����� ���� ù��° ȭ�� ��ġ    
        rightMonBottomPos = 1;                                 % ���� ����� �ٴ�. * ����: monPosition(secondaryMonitor,2)�� �̻���
        rightMonWidth = monPosition(primaryMonitor,3);    % ���� ����� �¿� ����
        rightMonHeight = monPosition(primaryMonitor,4); % ���� ����� ���Ʒ� ����
        
       
    end

    % C. figure ��ġ ����
    % * ����: [����� ���� ��迡������,����� �ٴ� ��迡������,�¿� ����,���Ʒ� ����]
    % * ����: 1) ���� ���� ����, figure ������ �ø�. 2) �������� ���� text �ڽ� ǥ��
    
    % ���� �����
    leftMonModifiedLeftPos ...             % ���� ����� ���� ��ǥ
        = leftMonLeftPos + figSideBorderThick; 
    leftMonModifiedBottomPos ...           % ���� ����� �ٴ� ��ǥ
        = leftMonBottomPos + figSideBorderThick;
    leftMonBasicDividedWidth ...           % ���� ����� ���ҵ� �¿� ����
        = (leftMonWidth - leftMonWidthDivisionNo * 2 * figSideBorderThick) ...
        / leftMonWidthDivisionNo;    
    leftMonBasicDividedHeight ...       % ���� ����� ���ҵ� ���Ʒ� ����
        = (leftMonHeight - leftMonHeightDivisionNo * bothThick) ...
        / leftMonHeightDivisionNo;
    
    leftMonPos01 ...
        = [leftMonModifiedLeftPos + (leftMonBasicDividedWidth * 0) ...
        ,leftMonModifiedBottomPos + (leftMonBasicDividedHeight + bothThick) * 1 ...
        ,leftMonBasicDividedWidth * 3 ...
        ,leftMonBasicDividedHeight * 2];

    leftMonPos02 ...
        = [leftMonModifiedLeftPos + (leftMonBasicDividedWidth * 0) ...
        ,leftMonModifiedBottomPos + (leftMonBasicDividedHeight + bothThick) * 0 ...
        ,leftMonBasicDividedWidth * 1 ...
        ,leftMonBasicDividedHeight * 1];

    leftMonPos03 ...
        = [leftMonModifiedLeftPos + (leftMonBasicDividedWidth * 1) ...
        ,leftMonModifiedBottomPos + (leftMonBasicDividedHeight + bothThick) * 0 ...
        ,leftMonBasicDividedWidth * 1 ...
        ,leftMonBasicDividedHeight * 1];

    leftMonPos04 ...
        = [leftMonModifiedLeftPos + (leftMonBasicDividedWidth * 2) ...
        ,leftMonModifiedBottomPos + (leftMonBasicDividedHeight + bothThick) * 0 ...
        ,leftMonBasicDividedWidth * 1 ...
        ,leftMonBasicDividedHeight * 1];
    
    leftMonPos05 ...
        = [leftMonModifiedLeftPos + (leftMonBasicDividedWidth * 3) ...
        ,leftMonModifiedBottomPos + (leftMonBasicDividedHeight + bothThick) * 0 ...
        ,leftMonBasicDividedWidth * 1 ...
        ,leftMonBasicDividedHeight * 1];

    leftMonPos06 ...
        = [leftMonModifiedLeftPos + (leftMonBasicDividedWidth * 4) ...
        ,leftMonModifiedBottomPos + (leftMonBasicDividedHeight + bothThick) * 0 ...
        ,leftMonBasicDividedWidth * 1 ...
        ,leftMonBasicDividedHeight * 1];

    % ���� �����    
    rightMonModifiedLeftPos ...             % ���� ����� ���� ��ǥ
        = rightMonLeftPos + figSideBorderThick;
    rightMonModifiedBottomPos ...           % ���� ����� �ٴ� ��ǥ
        = rightMonBottomPos + figSideBorderThick;       
    rightMonBasicDividedWidth ...           % ���� ����� ���ҵ� �¿� ����
        = (rightMonWidth - rightMonWidthDivisionNo * 2 * figSideBorderThick) ... % �ణ ����
        / rightMonWidthDivisionNo;
    rightMonBasicDividedHeight ...          % ���� ����� ���ҵ� ���Ʒ� ����
        = (rightMonHeight - rightMonHeightDivisionNo * bothThick) ....
        / rightMonHeightDivisionNo;
    
    rightMonPos01 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 0) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 2 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos02 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 1) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 2 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos03 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 2) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 2 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos04 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 3) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 2 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos05 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 4) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 2 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos06 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 5)  ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 2 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos07 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 0)  ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 1 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos08 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 1)  ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 1 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos09 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 2)  ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 1 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos10 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 3)  ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 1 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos11 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 4)  ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 1 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos12 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 5)  ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 1 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos13 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 0)  ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 0 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos14 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 1) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 0 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos15 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 2) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 0 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos16 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 3) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 0 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    rightMonPos17 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 4) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 0 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];
    
    rightMonPos18 ...
        = [rightMonModifiedLeftPos + (rightMonBasicDividedWidth * 5) ...
        ,rightMonModifiedBottomPos + (rightMonBasicDividedHeight + bothThick) * 0 ...
        ,rightMonBasicDividedWidth * 1 ...
        ,rightMonBasicDividedHeight * 1];

    %--------------------------------------------------------------------------
    % 2) figure �ڵ�

    Hf_01 = figure(1);
    set(gcf,'Units','Pixel','Position',leftMonPos01,'MenuBar','none');
    Hf_02 = figure(2);
    set(gcf,'units','Pixel','position',leftMonPos02,'MenuBar','none');
    Hf_03 = figure(3);
    set(gcf,'units','Pixel','position',leftMonPos03,'MenuBar','none');
    Hf_04 = figure(4);
    set(gcf,'units','Pixel','position',leftMonPos04,'MenuBar','none');
    Hf_05 = figure(5);
    set(gcf,'units','Pixel','position',leftMonPos05,'MenuBar','none');
    Hf_06 = figure(6);
    set(gcf,'units','Pixel','position',leftMonPos06,'MenuBar','none');
    Hf_07 = figure(7);
    set(gcf,'units','Pixel','position',rightMonPos01,'MenuBar','none');
    Hf_08 = figure(8);
    set(gcf,'units','Pixel','position',rightMonPos02,'MenuBar','none');
    Hf_09 = figure(9);
    set(gcf,'units','Pixel','position',rightMonPos03,'MenuBar','none');
    Hf_10 = figure(10);
    set(gcf,'units','Pixel','position',rightMonPos04,'MenuBar','none');
    Hf_11 = figure(11);
    set(gcf,'units','Pixel','position',rightMonPos05,'MenuBar','none');
    Hf_12 = figure(12);
    set(gcf,'units','Pixel','position',rightMonPos06,'MenuBar','none');
    Hf_13 = figure(13);
    set(gcf,'units','Pixel','position',rightMonPos07,'MenuBar','none');
    Hf_14 = figure(14);
    set(gcf,'units','Pixel','position',rightMonPos08,'MenuBar','none');
    Hf_15 = figure(15);
    set(gcf,'units','Pixel','position',rightMonPos09,'MenuBar','none');
    Hf_16 = figure(16);
    set(gcf,'units','Pixel','position',rightMonPos10,'MenuBar','none');
    Hf_17 = figure(17);
    set(gcf,'units','Pixel','position',rightMonPos11,'MenuBar','none');
    Hf_18 = figure(18);
    set(gcf,'units','Pixel','position',rightMonPos12,'MenuBar','none');
    Hf_19 = figure(19);
    set(gcf,'units','Pixel','position',rightMonPos13,'MenuBar','none');
    Hf_20 = figure(20);
    set(gcf,'units','Pixel','position',rightMonPos14,'MenuBar','none');
    Hf_21 = figure(21);
    set(gcf,'units','Pixel','position',rightMonPos15,'MenuBar','none');
    Hf_22 = figure(22);
    set(gcf,'units','Pixel','position',rightMonPos16,'MenuBar','none');
    Hf_23 = figure(23);
    set(gcf,'units','Pixel','position',rightMonPos17,'MenuBar','none');
    Hf_24 = figure(24);
    set(gcf,'units','Pixel','position',rightMonPos18,'MenuBar','none');

end

%--------------------------------------------------------------------------
% 3) ��� �м��� ���� ���� �ʱ�ȭ

% ���ȯ�� �з� ���
ALLUVIAL_CHANNEL = 1;               % ���� �ϵ�
BEDROCK_CHANNEL = 2;                % ��ݾ� �ϻ� �ϵ�
BEDROCK_EXPOSED_HILLSLOPE = 3;      % ��ݾ��� ����� ���
SOIL_MANTLED_HILLSLOPE = 4;         % ���������� ���� ���

% �̿� ���� ��ǥ�� ���ϱ� ���� offset
% * ����: ���ʿ� �ִ� �̿� ������ �ݽð� ������
offsetY = [0; -1; -1; -1; 0; 1; 1; 1];
offsetX = [1; 1; 0; -1; -1; -1; 0; 1];

% * ����: �¿� ��谡 ����Ǵ� ������ ��� offsetX ����
if IS_LEFT_RIGHT_CONNECTED == true
    
    X_INI_OffsetX = offsetX;
    X_INI_OffsetX(4:6) = X - 1;

    X_MAX_OffsetX = offsetX;
    X_MAX_OffsetX(1:2) = -(X - 1);
    X_MAX_OffsetX(8) = -(X - 1);
    
end

distanceY = Y * dX;                 % Y�� �Ÿ�
distanceX = X * dX;                 % X�� �Ÿ�

[arrayXForGraph,arrayYForGraph] ...
    = meshgrid(0.5*dX:dX:distanceX-0.5*dX,0.5*dX:dX:distanceY-0.5*dX);

% ������ ù ����� GPSS ���� Ƚ�� ����
% * ����: GPSS ������ �ߴܵ� ���� �м��ϴ��� Ȯ����
if INIT_TIME_STEP_NO ~= 1    
    % ���ӵǴ� ���̶��, ���� ������ ���� ������� �� ���� ū ���� �Է���
    initIthStep = (INIT_TIME_STEP_NO - 1) / WRITE_INTERVAL + 1;    
else    
    % ���ӵǴ� ���� �ƴ϶�� 1�� ����
    initIthStep = 1;    
end

% ������ ������ ����� GPSS ���� Ƚ�� ����
endStep ...                         % ����� ���Ͽ� ��ϵ� Ƚ��
    = floor(TIME_STEPS_NO/WRITE_INTERVAL * achievedRatio);


% �׷��� �����ֱ� Ƚ�� �� �ֿ� 2���� ���� ���� Ƚ�� ���� ����
totalGraphShowTimesNo ...                            % �׷����� �����ִ� �� Ƚ��
    = ceil(endStep / GRAPH_INTERVAL);
ithGraph = 0;                                        % ������� ������ �׷��� Ƚ��
dGraphShowTime = WRITE_INTERVAL * GRAPH_INTERVAL;    % �׷��� ���� �ð�

% �ֿ� ������ ����(����->mat)�ϴ� ���� ����
% * ����: �� ���� �������� ������. 2���� ������ ū ��������, 1���� (�ð迭)
%   ������ ���� �������� totalGraphShowTimesNo�� �����ϰ� ������
% * ����: ���� ������ �׷��� �����ֱ� Ƚ������ ũ�� �����ֱ� Ƚ���� ���Ⱓ������
%   ��ü��
if EXTRACT_INTERVAL > totalGraphShowTimesNo
    EXTRACT_INTERVAL = totalGraphShowTimesNo;
end

% �ֿ� 2���� ������ �����ϴ� �� Ƚ��
totalExtractTimesNo = floor(totalGraphShowTimesNo / EXTRACT_INTERVAL);

ithExtractTime = 0;                 % mat ���� ����� ���� ���� �ʱ�ȭ

% ���� ���� Ⱦ�ܸ鵵 �м� ���� ����
upperCrossProfileY = 45;
middleCrossProfileY = 70;
lowerCrossProfileY = 95;
upperCrossProfileZone = upperCrossProfileY-2:upperCrossProfileY+2;
middleCrossProfileZone = middleCrossProfileY-2:middleCrossProfileY+2;
lowerCrossProfileZone = lowerCrossProfileY-2:lowerCrossProfileY+2;

% mat ���Ͽ� ����� �ֿ� ����
% 2 ����
extSedimentThick = zeros(mRows,nCols,totalExtractTimesNo+1);
extBedrockElev = zeros(mRows,nCols,totalExtractTimesNo+1);
extWeatheringProduct = zeros(mRows,nCols,totalExtractTimesNo);
extDSedThickByHillslopePerDT = zeros(mRows,nCols,totalExtractTimesNo);
extDSedThickByRapidMassPerDT = zeros(mRows,nCols,totalExtractTimesNo);
extDBedrockElevByRapidMassPerDT = zeros(mRows,nCols,totalExtractTimesNo);
extDSedThickByFluvialPerDT = zeros(mRows,nCols,totalExtractTimesNo);
extDBedrockElevByFluvialPerDT = zeros(mRows,nCols,totalExtractTimesNo);
extChanBedSedBudget = zeros(mRows,nCols,totalExtractTimesNo);
extUpslopeArea = zeros(mRows,nCols,totalExtractTimesNo);
extTransportMode = zeros(mRows,nCols,totalExtractTimesNo);
extFacetFlowSlope = zeros(mRows,nCols,totalExtractTimesNo);
% 1����
% * ����: �׷����� ȭ�鿡 ������ �� ��� ������
extEastDrainageDensity = zeros(totalGraphShowTimesNo,1);
extWestDrainageDensity = zeros(totalGraphShowTimesNo,1);
extEastSoilMantledHillRatio = zeros(totalGraphShowTimesNo,1);
extWestSoilMantledHillRatio = zeros(totalGraphShowTimesNo,1);
extEastBedrockExposedHillRatio = zeros(totalGraphShowTimesNo,1);
extWestBedrockExposedHillRatio = zeros(totalGraphShowTimesNo,1);
extEastAlluvialChanRatio = zeros(totalGraphShowTimesNo,1);
extWestAlluvialChanRatio = zeros(totalGraphShowTimesNo,1);
extEastBedrockChanRatio = zeros(totalGraphShowTimesNo,1);
extWestBedrockChanRatio = zeros(totalGraphShowTimesNo,1);
extEastRapidMassFreq = zeros(totalGraphShowTimesNo,1);
extWestRapidMassFreq = zeros(totalGraphShowTimesNo,1);
extEastUpperHillRegolithThick = zeros(totalGraphShowTimesNo,1);
extEastMiddleHillRegolithThick = zeros(totalGraphShowTimesNo,1);
extEastBottomHillRegolithThick = zeros(totalGraphShowTimesNo,1);
extEastUpperChannelSedThick = zeros(totalGraphShowTimesNo,1);
extEastMiddleChannelSedThick = zeros(totalGraphShowTimesNo,1);
extEastBottomChannelSedThick = zeros(totalGraphShowTimesNo,1);
extEastUpperHillDSedThick = zeros(totalGraphShowTimesNo,1);
extEastMiddleHillDSedThick = zeros(totalGraphShowTimesNo,1);
extEastLowerHillDSedThick = zeros(totalGraphShowTimesNo,1);
extEastUpperChannelDBedrockElev = zeros(totalGraphShowTimesNo,1);
extEastMiddleChannelDBedrockElev = zeros(totalGraphShowTimesNo,1);
extEastLowerChannelDBedrockElev = zeros(totalGraphShowTimesNo,1);
extEastUpperChannelDSedThick = zeros(totalGraphShowTimesNo,1);
extEastMiddleChannelDSedThick = zeros(totalGraphShowTimesNo,1);
extEastLowerChannelDSedThick = zeros(totalGraphShowTimesNo,1);
extEastUpperUpliftedHeight = zeros(totalGraphShowTimesNo,1);
extEastMiddleUpliftedHeight = zeros(totalGraphShowTimesNo,1);
extEastLowerUpliftedHeight = zeros(totalGraphShowTimesNo,1);
extEastUpperChannelWeatheringRate = zeros(totalGraphShowTimesNo,1);
extEastMiddleChannelWeatheringRate = zeros(totalGraphShowTimesNo,1);
extEastLowerChannelWeatheringRate = zeros(totalGraphShowTimesNo,1);
extEastUpperHillslopeWeatheringRate = zeros(totalGraphShowTimesNo,1);
extEastMiddleHillslopeWeatheringRate = zeros(totalGraphShowTimesNo,1);
extEastLowerHillslopeWeatheringRate = zeros(totalGraphShowTimesNo,1);
extEastUpperFluvialTransportCapacity = zeros(totalGraphShowTimesNo,1);
extEastMiddleFluvialTransportCapacity = zeros(totalGraphShowTimesNo,1);
extEastLowerFluvialTransportCapacity = zeros(totalGraphShowTimesNo,1);

% ������ ���� ����
cumsumUpliftRate = cumsum(upliftRateTemporalDistribution);

% Ⱦ�ܻ� ��ȭ �׷����� ���� �� ���� ���� ���� �ʱ�ȭ
oldBiggestY = 0;
axisX = 0.5*dX:dX:distanceX-0.5*dX;

% �ݺ��� �� ���� ����
L = ones(mRows,nCols) * 9;                              % �ܰ� ��迡�� 0�� �ƴ� ������ ���� ����
eastMeanElev = zeros(totalGraphShowTimesNo,1);                  % ���� �������� ��� ��
eastMeanSlope = zeros(totalGraphShowTimesNo,1);                 % ���� �������� ��� ���
eastMeanSedimentThick = zeros(totalGraphShowTimesNo,1);         % ���� �������� ��� ������ �β�
eastMeanWeatheringProduct = zeros(totalGraphShowTimesNo,1);     % ���� �������� ��� ǳȭ��
eastMeanErosionRate = zeros(totalGraphShowTimesNo,1);           % ���� �������� ��� ħ����
eastMeanUpliftedHeight = zeros(totalGraphShowTimesNo,1);        % ���� �������� ��� ������
westMeanElev = zeros(totalGraphShowTimesNo,1);                  % ���� �������� ��� ��
westMeanSlope = zeros(totalGraphShowTimesNo,1);                 % ���� �������� ��� ���
westMeanSedimentThick = zeros(totalGraphShowTimesNo,1);         % ���� �������� ��� ������ �β�
westMeanWeatheringProduct = zeros(totalGraphShowTimesNo,1);     % ���� �������� ��� ǳȭ��
westMeanErosionRate = zeros(totalGraphShowTimesNo,1);           % ���� �������� ��� ħ����
westMeanUpliftedHeight = zeros(totalGraphShowTimesNo,1);        % ���� �������� ��� ������
upliftedHeight = zeros(mRows,nCols);                    % �����ð� ������ [m/dT]

%==========================================================================
% 2. �ֿ� �м� 

% 1) ���� �۾�

% (1) �ʱ� ������ �β��� ��ݾ� �� ����
% * ����: �̴� �ʱ� ���� �� �ʱ� ������ �β��� ��� ���Ͽ� ����ϱ� ������
initSedThick = fscanf(FID_SEDTHICK,'%f',[mRows,nCols]);
initBedrockElev = fscanf(FID_BEDROCKELEV,'%f',[mRows,nCols]);

% �ʱ� ��ݾϰ��� ������ �β��� �����
extSedimentThick(:,:,1) = initSedThick;
extBedrockElev(:,:,1) = initBedrockElev;

% (2) �׷��� ��� ���� ���� ����
startedStepNo = startedTimeStepNo / WRITE_INTERVAL;

% 2) ���Ͽ��� i��° ���ǰ���� �а� �̸� �׷����� ǥ���ϰ� �ֿ� ������ ����
%    �������� ������
for ithStep = initIthStep:endStep
    
    fprintf('%i\n',ithStep); % ���� Ƚ�� ���
    
    % (1) i��° ����� �� ���Ͽ��� ����
    
    % * ����: ���Ͽ� ��ϵ� ������ �β� �� ��ݾ� ���� GPSSMain()���� AdjustBoundary,
    %   Uplift �Լ��� �ݿ��Ǿ����� ���� �ۿ��� �ݿ����� ���� ������ ����
    sedimentThick ...                   % (���� �ۿ� ����) ������ �β�
        = fscanf(FID_SEDTHICK,'%f',[mRows,nCols]);
    
    bedrockElev ...                     % (���� �ۿ� ����) ��ݾ� ��
        = fscanf(FID_BEDROCKELEV,'%f',[mRows,nCols]);
    
    weatheringProduct ...               % ǳȭ�� [m/dT]
        = fscanf(FID_WEATHER,'%f',[mRows,nCols]);
    
    dSedThickByHillslopePerDT ...       % ����ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
        = fscanf(FID_dSEDTHICK_BYHILLSLOPE,'%f',[mRows,nCols]);
    
    dSedThickByRapidMassPerDT ... % ���� ����ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
        = fscanf(FID_dSEDTHICK_BYRAPIDMASS,'%f',[mRows,nCols]);
    
    dBedrockElevByRapidMassPerDT ... % ���� ����ۿ뿡 ���� ��ݾ� �� ��ȭ�� [m^3/m^2 dT]
        = fscanf(FID_dBEDROCKELEV_BYRAPIDMASS,'%f',[mRows,nCols]);
    
    dSedThickByFluvialPerDT ...         % ��õ�ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
        = fscanf(FID_dSEDTHICK_BYFLUVIAL,'%f',[mRows,nCols]);
    
    dBedrockElevByFluvialPerDT ...      % ��õ�ۿ뿡 ���� ��ݾ� �� ��ȭ��[m^3/m^2 dT]
        = fscanf(FID_dBEDROCKELEV_BYFLUVIAL,'%f',[mRows,nCols]);
    
    chanBedSedBudget ...                % �ϵ� �� �ϻ� ������ ���� ���� [m^3/dT]
        = fscanf(FID_CHANBEDSEDBUDGET,'%f',[mRows,nCols]);
    
    % (2) [�׷���] i��° ����� �����ش�.
    if mod(ithStep,GRAPH_INTERVAL) == 0 ...
        && floor(ithStep/GRAPH_INTERVAL) > 0 && ithStep >= startedStepNo
        
    
        % A. �׷��� �� timeStep ���� ���� ����
        ithTimeStep = ithStep * WRITE_INTERVAL;     % TIME_STEP_NO
        simulatingTime = ithTimeStep * dT;          % �������� �����Ⱓ�� ����� �⵵ [yr]
        ithGraph = ithGraph + 1;                    % �׷��� ��� Ƚ��
        
        % (���ǱⰣ ��ü ����� �����ִ� �׷����� ����) ���� �⵵ ���
        if ithGraph == 1
            firstGraphShowTime = ithTimeStep * dT;
        end
        
        elev = bedrockElev + sedimentThick;         % �� ����            
        
        upliftedHeightPerDT ...                     % ������ ���� [m/dT]
            = meanUpliftRateSpatialDistribution(Y_INI:Y_MAX,X_INI:X_MAX) ...
            / meanUpliftRateAtUpliftAxis ...
            * upliftRateTemporalDistribution(ithTimeStep);        
        
        %------------------------------------------------------------------
        % B. i��° (3����) DEM
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        figure(Hf_01);

        surf(arrayYForGraph,arrayXForGraph,elev(Y_INI:Y_MAX,X_INI:X_MAX))
        % meshz(arrayYForGraph,arrayXForGraph,elev(Y_INI:Y_MAX,X_INI:X_MAX))        

        view(25,30)            % �׷��� ���� ����

        grid(gca,'on')        
        set(gca,'DataAspectRatio',[1 1 0.25],'ZLim',[0 1500])
        endYAxisDistance = 30;
        set(gca,'YTick',0:endYAxisDistance/6:endYAxisDistance ...
            ,'YTickLabel',{'30 Km','','20','','10','','0'} ...
            ,'XTick',[] ...
            ,'XTickLabel',[])
        
        shading interp
        
        colormap(demcmap(elev(Y_INI:Y_MAX,X_INI:X_MAX)))        
        colorbar
        
        tmpTitle = [int2str(simulatingTime) 'th Elevation'];
        title(tmpTitle)        
        
        end
        
        %------------------------------------------------------------------
        % C.i��° �� ���
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        figure(Hf_02);
        
%         contourNo = 16;                             % ��� ���� ����
        % ���ǱⰣ �ִ�,�ּ� ���� �� ���
%         contourNo = ceil(((max(max(elev(Y_INI:Y_MAX,X_INI:X_MAX))) ...
%             - min(min(elev(Y_INI:Y_MAX,X_INI:X_MAX)))) * contourNo) ...
%             / diffBtwMostMaxMin);
        
%         contourf(arrayXForGraph,arrayYForGraph ...  % �����
%             ,elev(Y_INI:Y_MAX,X_INI:X_MAX),contourNo,'DisplayName','elev');        

%         if max(max(elev(Y_INI:Y_MAX,X_INI:X_MAX))) > 1
%           contourcmap(1,'jet','colorbar','on');        
%         end
%         colorbar   
        
        imshow(elev(Y_INI:Y_MAX,X_INI:X_MAX),[],'InitialMagnification','fit')
        colormap jet
        set(gca,'YDir','reverse')                   % Y�� ������ �ݴ��
        set(gca,'DataAspectRatio',[1 1 1]);         % �� �� ������ ũ��� ����
        colorbar;            
        
        tmpTitle = [int2str(simulatingTime) 'th Elevation'];
        title(tmpTitle);       
        
        end
        
        %------------------------------------------------------------------
        % D. i��° ������ �β�
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        % ��� ���� ��鹰���̵��� ���� �� ��ȭ�� ���� ���
        % * ����: ��õ�� �����ϴ� ���� ���� ����� ������ ���Է��� �ſ� ũ����
        %   ����ۿ뿡 ���� ���ⷮ�� �ſ� ���, ������ �β��� �ſ� ���� ������
        %   ������. ���ǱⰣ �Ĺݺη� ������(�� ��õ�� �����ϴ� ���� ����������)
        %   �̷� ������ �پ�� ������ �����. ������ �̷� ���� �������� ������
        %   ������ �����ϱⰡ ���� ����. ���� ����� �߽����� ǥ��������
        %   3��������� ���ʷ� ����
        % => ����� ��� ������ overland flow erosion�� ����ϱ� ������ ������
        
        % mu = mean2(sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX));
        % sigma = std2(sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX));
        
        % if mu - sigma*3 < 0
        %     minY = 0;
        % else
        %     minY = mu - sigma*3;
        % end
        
        figure(Hf_03);
        
        imagesc([0.5*dX dX distanceX-0.5*dX] ...    % imagesc �׷���
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX))
        
        % => ����� ��� ������ overland flow erosion�� ����ϱ� ������ CLim��
        %    ������
        % set(gca,'DataAspectRatio',[1 1 1],'CLim',[minY, mu + sigma*3])
        set(gca,'DataAspectRatio',[1 1 1])
        
        colorbar
        
        tmpTitle = [int2str(simulatingTime) 'th Sediment Thickness'];
        title(tmpTitle)
       
        end
        
        %------------------------------------------------------------------
        % E. i��° ���
        
        % A) ���� ���� �˰����� �̿��� ����� ���
        [facetFlowDirection ...     % ����
        ,facetFlowSlope ...         % ���
        ,e1LinearIndicies ...       % ���� ��(e1) ����
        ,e2LinearIndicies ...       % ���� ��(e2) ����
        ,outputFluxRatioToE1 ...    % ���� ��(e1)���� ������
        ,outputFluxRatioToE2] ...   % ���� ��(e2)���� ������
            = CalcInfinitiveFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,QUARTER_PI,HALF_PI,elev,dX ...
            ,sE0LinearIndicies,s3E1LinearIndicies,s3E2LinearIndicies);
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        % B) i��° ���
        figure(Hf_04);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,facetFlowSlope(Y_INI:Y_MAX,X_INI:X_MAX));
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        tmpTitle = [int2str(simulatingTime) 'th Gradient'];
        title(tmpTitle)
        
        %------------------------------------------------------------------
        % F. i��° ǳȭ��
        
        figure(Hf_05);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,weatheringProduct(Y_INI:Y_MAX,X_INI:X_MAX));
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        tmpTitle = [int2str(simulatingTime) 'th Weathering Product'];
        title(tmpTitle)
        
        %------------------------------------------------------------------
        % G. i��° ����ۿ뿡 ���� ������ �β� ��ȭ��
        
        figure(Hf_06);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,dSedThickByHillslopePerDT(Y_INI:Y_MAX,X_INI:X_MAX));
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        tmpTitle = [int2str(simulatingTime) 'th dSedThick By Slow Mass'];
        title(tmpTitle)
        
        %------------------------------------------------------------------
        % H. i��° ���� ����ۿ뿡 ���� ������ �β� ��ȭ��
        
        figure(Hf_07);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,dSedThickByRapidMassPerDT(Y_INI:Y_MAX,X_INI:X_MAX));
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        tmpTitle = [int2str(simulatingTime) 'th dSedThick By Rapid Mass'];
        title(tmpTitle)
        
        %------------------------------------------------------------------
        % I. i��° ���� ����ۿ뿡 ���� ��ݾ� �� ��ȭ��
        
        figure(Hf_08);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,dBedrockElevByRapidMassPerDT(Y_INI:Y_MAX,X_INI:X_MAX));
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        tmpTitle = [int2str(simulatingTime) 'th dBedrockElev By Rapid Mass'];
        title(tmpTitle)
        
        end
        
        %------------------------------------------------------------------
        % J. i��° flooded region �� ��������
        
        % A) �ִ� �Ϻ� ��� ���� �˰����� �̿��� ����� ���
        [steepestDescentSlope ...   % ���
        ,slopeAllNbr ...            % 8�� �̿� ������ ���
        ,SDSFlowDirection ...       % ����
        ,SDSNbrY ...                % ���� �� Y ��ǥ��
        ,SDSNbrX] ...               % ���� �� X ��ǥ��
            = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
            ,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX ...
            ,IS_LEFT_RIGHT_CONNECTED ...
            ,ithNbrYOffset,ithNbrXOffset ...
            ,sE0LinearIndicies,s3IthNbrLinearIndicies);
        
        % B) ������ ���ǵ��� ���� ���� ������ ������
        % * sink�� ������ �ο��ϰ�, flooded region�� ������ �缳����
        [flood ...                      % flooded region
        ,SDSNbrY ...                    % ������ ���� ���� Y ��ǥ��
        ,SDSNbrX ...                    % ������ ���� ���� X ��ǥ��
        ,SDSFlowDirection ...           % ������ (�ִ��Ϻΰ�� ���� �˰�����) ����
        ,steepestDescentSlope ...       % ������ (�ִ��Ϻΰ�� ���� �˰�����) ���
        ,integratedSlope ...            % ������ (���� ���� �˰���) ���
        ,floodedRegionIndex ...         % flooded region ����
        ,floodedRegionCellsNo ...       % �� flooded region ���� �� ����
        ,floodedRegionLocalDepth ...    % flooded region ���� ���ⱸ ������ ����
        ,floodedRegionTotalDepth ...    % local depth �� ��
        ,floodedRegionStorageVolume] ...% flooded region �� ���差
            = ProcessSink(mRows,nCols,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA ...
            ,elev,ithNbrYOffset,ithNbrXOffset ...
            ,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
            ,slopeAllNbr,steepestDescentSlope ...
            ,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection);
        
        % C) flooded region �׷���
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        figure(Hf_09);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,flood(Y_INI:Y_MAX,X_INI:X_MAX))
        set(gca,'DataAspectRatio',[1 1 1],'CLim',[0 2])        
        colormap(jet(3))
        labels = {'Unflooded','Sink','Flooded'};
        lcolorbar(labels,'fontweight','bold')       
        tmpTitle = [int2str(simulatingTime) 'th Flooded Region'];
        title(tmpTitle)
        
        end
        
        % D) ���� ����[m^3/dT]

        % a. ������ �� ������ ����
        elevForSorting = elev;

        % b. flooded region�� ������
        % * ���� : �����ϴ� ���� �������� - inf�� �Է���
        elevForSorting(flood == FLOODED) = - inf;

        % c. ���� �� ������ �����ϰ� ���� Y,X ��ǥ���� ����
        vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
        sortedYXElevForUpstreamFlow = [vectorY,vectorX,vectorElev];
        sortedYXElevForUpstreamFlow = sortrows(sortedYXElevForUpstreamFlow,-3);

        % d. AccumulateUpstreamFlow �Լ��� ��� �� ��
        consideringCellsNoForUpstreamFlow = find(vectorElev > - inf);
        consideringCellsNoForUpstreamFlow ...
            = size(consideringCellsNoForUpstreamFlow,1);

        % e. �������� [m^3/dT]
        [annualDischarge1 ...   % �������� [m^3/dT]
        ,isOverflowing] ...     % flooded region ������ �ʰ� ���� �±�
            = AccumulateUpstreamFlow(mRows,nCols ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,sortedYXElevForUpstreamFlow ...
            ,consideringCellsNoForUpstreamFlow ...
            ,OUTER_BOUNDARY,annualRunoff ...
            ,flood,floodedRegionCellsNo ...
            ,floodedRegionStorageVolume,floodedRegionIndex ...
            ,facetFlowDirection,e1LinearIndicies,e2LinearIndicies ...
            ,outputFluxRatioToE1,outputFluxRatioToE2,SDSNbrY,SDSNbrX);    

        % E) ��������

        % a. �� ������� [m^3/s]
        meanDischarge = annualDischarge1 / SECPERYEAR;

        % b. �������� [m^3/s]
        bankfullDischarge = kqb * meanDischarge .^ mqb;
        
        % F) �������� �׷���
        if SHOW_GRAPH == SHOW_GRAPH_YES
        
        figure(Hf_10);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,log10(bankfullDischarge(Y_INI:Y_MAX,X_INI:X_MAX)))
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        tmpTitle = [int2str(simulatingTime) 'th Bankfull Discharge(log10)'];
        title(tmpTitle)
        
        end
        
        %------------------------------------------------------------------
        % K. i��° ��õ�ۿ뿡 ���� ������ �β� ��ȭ��
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        figure(Hf_11);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,dSedThickByFluvialPerDT(Y_INI:Y_MAX,X_INI:X_MAX))
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        
        % * ����: ����� ��ȸ�ϴ� ������ �����ؼ�, �߰����� ������ �ľ��ϱ� ����
        %   ǥ������ 3�� ������ �׷����� ǥ����
        mu = mean2(dSedThickByFluvialPerDT(Y_INI:Y_MAX,X_INI:X_MAX));
        sigma = std2(dSedThickByFluvialPerDT(Y_INI:Y_MAX,X_INI:X_MAX));
        set(gca,'CLim',[mu - sigma*3, mu + sigma*3])
        
        tmpTitle = [int2str(simulatingTime) 'th dSedThick By Fluvial'];
        title(tmpTitle)
        
        end
        
        %------------------------------------------------------------------
        % L. i��° ��õ�ۿ뿡 ���� ��ݾ� �� ��ȭ��
        if SHOW_GRAPH == SHOW_GRAPH_YES
        
        figure(Hf_12);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,dBedrockElevByFluvialPerDT(Y_INI:Y_MAX,X_INI:X_MAX))
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        tmpTitle = [int2str(simulatingTime) 'th dBedrockElev By Fluvial'];
        title(tmpTitle)
        
        end
        
        %------------------------------------------------------------------
        % M. i��° �������ȯ�� �з�
        
        % (A) �������ȯ�� ���� �ʱ�ȭ
        transportMode = zeros(mRows,nCols);         % 0���� �ʱ�ȭ
        
        % (B) ��� ���� ��õ ���� ���� ������
        upslopeArea = annualDischarge1 ./ annualRunoff; % ��������: [m^3/yr]/[m/yr]
        
        channel ...                         % ��õ ���� �Ӱ�ġ�� ���� ��
            = ((upslopeArea .* integratedSlope .^ 2 >= channelInitiation) ...
            & (integratedSlope ~= -inf)) ... % �ʱ� ��簪�� ������
            | (upslopeArea / CELL_AREA >= criticalUpslopeCellsNo) ...
            | (flood == FLOODED);
        
        hillslope = ~channel;               % ��� ��
        
        % (C) ��� �з�        
        transportMode(hillslope) ...        % ���������� ���� ���
            = SOIL_MANTLED_HILLSLOPE;
        
        bedrockExposedHillslope = hillslope & ...   % ��ݾ����� ����� ���
            (sedimentThick < ...
            - (dSedThickByHillslopePerDT + dSedThickByFluvialPerDT) );
        
        transportMode(bedrockExposedHillslope) ...
            = BEDROCK_EXPOSED_HILLSLOPE;    
        
        % (B) �ϵ� �з�            
        upslopeArea = annualDischarge1 ./ annualRunoff; % ��������: [m^3/yr]/[m/yr]

        transportMode(channel) = ALLUVIAL_CHANNEL;
        
        bedrockChannel = channel & (dBedrockElevByFluvialPerDT < 0);        
        transportMode(bedrockChannel) = BEDROCK_CHANNEL;
        
        % (C) �������ȯ�� �з� ����
        soilMantledHill = transportMode == SOIL_MANTLED_HILLSLOPE;
        soilMantledHillRatio = sum(soilMantledHill(:)) / (Y*X);
        
        bedrockExposedHill = transportMode == BEDROCK_EXPOSED_HILLSLOPE;
        bedrockExposedHillRatio = sum(bedrockExposedHill(:)) / (Y*X);
        
        alluvialChan = transportMode == ALLUVIAL_CHANNEL;
        alluvialChanRatio = sum(alluvialChan(:)) / (Y*X);
        
        bedrockChan = transportMode == BEDROCK_CHANNEL;
        bedrockChanRatio = sum(bedrockChan(:)) / (Y*X);
                
        % (D) �������ȯ�� �з� �׷���        
        if SHOW_GRAPH == SHOW_GRAPH_YES   
            
        % a. �ܰ���� ���� ����
        % * ����: �������ȯ���� 4������ �ƴ� ���, ���� ����� ���� �׷�����
        %   ����� �ٸ� �� �ֱ� ������ �ܰ� ��迡 �� ���� ������
        transportMode(Y_TOP_BND,X_LEFT_BND) = SOIL_MANTLED_HILLSLOPE;
        transportMode(Y_BOTTOM_BND,X_LEFT_BND) = BEDROCK_EXPOSED_HILLSLOPE;
        transportMode(Y_TOP_BND,X_RIGHT_BND) = ALLUVIAL_CHANNEL;
        transportMode(Y_BOTTOM_BND,X_RIGHT_BND) = BEDROCK_CHANNEL;
        
        % b. �׷���
        figure(Hf_13);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,transportMode(Y_INI:Y_MAX,X_INI:X_MAX))
        set(gca,'DataAspectRatio',[1 1 1])

        colormap(jet(4))
        labels = {'Bedrock Channel','Alluvial Channel' ...
            ,'Bedrock Exposed Hillslope','Soil-mantled Hillslope'};
        
        lcolorbar(labels,'fontweight','bold')
        tmpTitle = [int2str(simulatingTime) 'th Transport Mode' ...
            '(' int2str(round(soilMantledHillRatio * 100)) '/' ...
            int2str(round(bedrockExposedHillRatio * 100)) '/' ...
            int2str(round(alluvialChanRatio * 100)) '/' ...
            int2str(round(bedrockChanRatio * 100)) ')'];
        title(tmpTitle)
        
        end
        
        %------------------------------------------------------------------
        % N. ���� ħ�ķ�
        
        % (A) ���� ���ⷮ
        % * ����: �ʱ� ������ �ݿ��Ͽ��ؾ� �ùٸ� ���� ħ�ķ��� ����
        accumulatedUpliftedHeight = zeros(mRows,nCols);
        accumulatedUpliftedHeight(Y_INI:Y_MAX,X_INI:X_MAX) ...
            = (meanUpliftRateSpatialDistribution(Y_INI:Y_MAX,X_INI:X_MAX) ...
            ./ meanUpliftRateAtUpliftAxis) ...
            * cumsumUpliftRate(ithTimeStep) ...
            + initBedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
            + initSedThick(Y_INI:Y_MAX,X_INI:X_MAX);
        
        % (B) ���� ħ�ķ�
        accumulatedErosionRate = zeros(mRows,nCols);
        accumulatedErosionRate(Y_INI:Y_MAX,X_INI:X_MAX) ...
            = accumulatedUpliftedHeight(Y_INI:Y_MAX,X_INI:X_MAX)...
            - elev(Y_INI:Y_MAX,X_INI:X_MAX);
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        figure(Hf_14);
        set(gcf,'MenuBar','none')
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,accumulatedErosionRate(Y_INI:Y_MAX,X_INI:X_MAX))
        colorbar
        set(gca,'DataAspectRatio',[1 1 1])
        
        tmpTitle = [int2str(simulatingTime) 'th Acc Erosion Rate'];
        title(tmpTitle)
        
        end
        
        %------------------------------------------------------------------
        % O. Topographic Position Index
        filterSize = 3;                     % ���� ũ�� 
        
        % �¿찡 ����Ǿ��ٸ� �¿� �ܰ������ ���� ������
        
        % (���� ũ�⿡ ����)�¿� �ܰ����� �߰��ؾ��� �� ����
        boundMarginColsNo = filterSize - 1;
        
        modifiedDEM = zeros(mRows,nCols+boundMarginColsNo*2);
        modifiedDEM(:,X_LEFT_BND+boundMarginColsNo:X_RIGHT_BND+boundMarginColsNo) = elev;
        
        % �¿� �ܰ���� �� ����
        modifiedDEM(:,X_RIGHT_BND+boundMarginColsNo:X_RIGHT_BND+boundMarginColsNo*2) ...
            = modifiedDEM(:,X_INI+boundMarginColsNo:X_INI+boundMarginColsNo*2);
        modifiedDEM(:,X_LEFT_BND:X_LEFT_BND+boundMarginColsNo) ...
            = modifiedDEM(:,X_MAX:X_MAX+boundMarginColsNo);
        
        % ���� �ܰ���� �� ����
        modifiedDEM(Y_TOP_BND,:) = modifiedDEM(Y_INI,:);
        modifiedDEM(Y_BOTTOM_BND,:) = modifiedDEM(Y_MAX,:);
        
        diskFilter = fspecial('disk',filterSize);

        smoothedDEMDisk = imfilter(modifiedDEM,diskFilter);

        diffElevDisk = smoothedDEMDisk - modifiedDEM;
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
        
        figure(Hf_15);
        set(gcf,'MenuBar','none')
        imagesc(diffElevDisk(Y_INI:Y_MAX ...
            ,X_INI+boundMarginColsNo:X_MAX+boundMarginColsNo))
        colorbar
        
        % * ����: �ܰ���� �������� ���� ����� ���� �ſ� ����
        maxDiffElev = max(max(diffElevDisk(Y_INI:Y_MAX ...
            ,X_INI+boundMarginColsNo:X_MAX+boundMarginColsNo)));
        set(gca,'CLim',[-maxDiffElev maxDiffElev])
        
        set(gca,'DataAspectRatio',[1 1 1])
        
        tmpTitle = [int2str(simulatingTime) 'th TPI'];
        title(tmpTitle)
        
        end
        
        %------------------------------------------------------------------
        % P. ������ �������� �м��� �ľ��ϱ�
        % * �浿�� ��� ���������� ������ ���

        % (A) �� ���� ����
        %   - �¿�ܰ����� ��������.
        %   - �����ܰ����� ���ⱸ�� �����ϰ�� inf�� �����Ǿ� ����.
        %     ���� �̵��� �����ܰ���迡�� ���� ���� ���ⱸ�� ���� ������.
        %   - ���� watershed �Լ��� �̿��Ͽ� �м��踦 �ľ���
        sOldElev = elev(Y_TOP_BND:Y_BOTTOM_BND,X_INI:X_MAX);
        outletX = find(elev(Y_TOP_BND,:) ~= inf);
        outletElev = elev(Y_TOP_BND,outletX);
        sOldElev(Y_TOP_BND,:) = outletElev;
        
        
        % (B) ������ ������ ���ϴ� 2���� ���������� ����� ���� ����ũ �����
        %     * ����ũ�� ���� �ڷ������� ������ ���� true�� �����ؾ� ��.
        boundMask = false(mRows,X);
        boundMask(Y_TOP_BND,:) = true;
        boundMask(Y_BOTTOM_BND,:) = true;

        % (C) regional minimum ���Ÿ� ���� �� ����
        modifiedSOldElev = imimposemin(sOldElev,boundMask);
        
        % (D) ������ ���� �� �м��� ���� ����
        L(Y_TOP_BND:Y_BOTTOM_BND,X_INI:X_MAX) = watershed(modifiedSOldElev);
        EAST_DRAINAGE = L(Y_BOTTOM_BND,X_INI);
        WEST_DRAINAGE = L(Y_TOP_BND,X_INI);
        WATERSHED_DIVIDE = 0;

        % (E) ���� label�� �ð�ȭ
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        % a. �� ����
        figure(Hf_02);
        hold on

        % b. �м��踦 ���� �����̰� ��
        b = bwboundaries(L == WATERSHED_DIVIDE,4);
        b1 = b{1};
        x = b1(:,2);
        y = b1(:,1);
        plot(x,y,'r','LineWidth',2)     
        
        end
        
        %------------------------------------------------------------------
        % Q. Ⱦ�ܰ�� �Ӽ�
        
        % ������ ��ݴɷ� ���ϱ�
   
        % ���������� ���� [m]
        bankfullWidth = khw * bankfullDischarge .^ mhw;        
        
        fluvialTransportCapacity ...   % �ӽ� ������ ��� �ɷ�[m^3/subDT]
            = ( bankfullWidth ...
            .* ( kfa .* ( bankfullDischarge ./ bankfullWidth ) .^ mfa ...
            .* integratedSlope .^ nfa ) );
        
        % ���� ���� ���
        upperHillslope ...      % ��� ����
            = transportMode(upperCrossProfileZone,:) == SOIL_MANTLED_HILLSLOPE ...
            | transportMode(upperCrossProfileZone,:) == BEDROCK_EXPOSED_HILLSLOPE;
        upperChannel ...        % ��õ ����
            = transportMode(upperCrossProfileZone,:) == ALLUVIAL_CHANNEL ...
            | transportMode(upperCrossProfileZone,:) == BEDROCK_CHANNEL; 
        

        % ��� ��� ǳȭ�� �β�
        upperHillslopeSed = sedimentThick(upperCrossProfileZone,:);        
        extEastUpperHillRegolithThick(ithGraph,1) ...
            = mean(upperHillslopeSed(upperHillslope));
        
        % ��õ ��� ������ �β�
        upperChannelSed = sedimentThick(upperCrossProfileZone,:);       
        extEastUpperChannelSedThick(ithGraph,1) ...
            = mean(upperChannelSed(upperChannel));
        
        % ����ۿ뿡 ���� ������ �β� ��ȭ��
        upperHillDSedThick = dSedThickByHillslopePerDT(upperCrossProfileZone,:);
        extEastUpperHillDSedThick(ithGraph,1) ...
            = mean(upperHillDSedThick(upperHillslope));
        
        % ��ݾ� �ϻ� ħ����
        upperChannelDBedrockElev = dBedrockElevByFluvialPerDT(upperCrossProfileZone,:);
        extEastUpperChannelDBedrockElev(ithGraph,1) ...
            = mean(upperChannelDBedrockElev(upperChannel));
        
        % ��õ�� ���� ������ �β� ��ȭ��
        upperChannelDSedThick = dSedThickByFluvialPerDT(upperCrossProfileZone,:);
        extEastUpperChannelDSedThick(ithGraph,1) ...
            = mean(upperChannelDSedThick(upperChannel));
        
        % ������
        upperUpliftedHeight = upliftedHeightPerDT(upperCrossProfileZone,:);
        extEastUpperUpliftedHeight(ithGraph,1) = mean(upperUpliftedHeight(:));
        
        % ǳȭ��
        upperWeatheringRate = weatheringProduct(upperCrossProfileZone,:);
        extEastUpperChannelWeatheringRate(ithGraph,1) ...
            = mean(mean(upperWeatheringRate(upperChannel)));
        extEastUpperHillslopeWeatheringRate(ithGraph,1) ...
            = mean(mean(upperWeatheringRate(upperHillslope)));
        
        % ������ ��ݴɷ�
        upperFluvialTransportCapacity = fluvialTransportCapacity(upperCrossProfileZone,:);
        extEastUpperFluvialTransportCapacity(ithGraph,1) ...
            = mean(upperFluvialTransportCapacity(upperChannel));
             
        
        % ���� ���� �߷�
        middleHillslope ...     % ��� ����
            = transportMode(middleCrossProfileZone,:) == SOIL_MANTLED_HILLSLOPE ...
            | transportMode(middleCrossProfileZone,:) == BEDROCK_EXPOSED_HILLSLOPE;          
        middleChannel ...       % ��õ ����
            = transportMode(middleCrossProfileZone,:) == ALLUVIAL_CHANNEL ...
            | transportMode(middleCrossProfileZone,:) == BEDROCK_CHANNEL;                  
        
        % ��� ��� ǳȭ�� �β�
        middleHillslopeReg = sedimentThick(middleCrossProfileZone,:);
        extEastMiddleHillRegolithThick(ithGraph,1) ...
            = mean(middleHillslopeReg(middleHillslope));
        
        % ��õ ��� ������ �β�
        middleChannelSedThick = sedimentThick(middleCrossProfileZone,:);
        extEastMiddleChannelSedThick(ithGraph,1) ...
            = mean(middleChannelSedThick(middleChannel));
        
        % ����ۿ뿡 ���� ������ �β� ��ȭ��
        middleHillslopeDSedThick = dSedThickByHillslopePerDT(middleCrossProfileZone,:);
        extEastMiddleHillDSedThick(ithGraph,1) ...
            = mean(middleHillslopeDSedThick(middleHillslope));
        
        % ��ݾ� �ϻ� ħ����
        middleChannelDBedrockElev = dBedrockElevByFluvialPerDT(middleCrossProfileZone,:);
        extEastMiddleChannelDBedrockElev(ithGraph,1) ...
            = mean(middleChannelDBedrockElev(middleChannel));
        
        % ��õ�� ���� ������ �β� ��ȭ��
        middleChannelDSedThick = dSedThickByFluvialPerDT(middleCrossProfileZone,:);
        extEastMiddleChannelDSedThick(ithGraph,1) ...
            = mean(middleChannelDSedThick(middleChannel));
        
        % ������
        middleUpliftedHeight = upliftedHeightPerDT(middleCrossProfileZone,:);
        extEastMiddleUpliftedHeight(ithGraph,1) = mean(middleUpliftedHeight(:));   
        
        % ǳȭ��
        middleWeatheringRate = weatheringProduct(middleCrossProfileZone,:);
        extEastMiddleChannelWeatheringRate(ithGraph,1) ...
            = mean(mean(middleWeatheringRate(middleChannel)));
        extEastMiddleHillslopeWeatheringRate(ithGraph,1) ...
            = mean(mean(middleWeatheringRate(middleHillslope)));
        
        % ������ ��ݴɷ�
        middleFluvialTransportCapacity = fluvialTransportCapacity(middleCrossProfileZone,:);
        extEastMiddleFluvialTransportCapacity(ithGraph,1) ...
            = mean(middleFluvialTransportCapacity(middleChannel));
        
        
        % ���� ���� �Ϸ�
        bottomHillslope ...             % ��� ����
            = transportMode(lowerCrossProfileZone,:) == SOIL_MANTLED_HILLSLOPE ...
            | transportMode(lowerCrossProfileZone,:) == BEDROCK_EXPOSED_HILLSLOPE;    
        bottomChannel ...               % ��õ ����
            = transportMode(lowerCrossProfileZone,:) == ALLUVIAL_CHANNEL ...
            | transportMode(lowerCrossProfileZone,:) == BEDROCK_CHANNEL;  
        
        % ��� ��� ǳȭ�� �β�
        bottomHillReg = sedimentThick(lowerCrossProfileZone,:);
        extEastBottomHillRegolithThick(ithGraph,1) ...
            = mean(bottomHillReg(bottomHillslope));
        
        % ��õ ��� ������ �β�
        bottomChannelSedThick = sedimentThick(lowerCrossProfileZone,:);
        extEastBottomChannelSedThick(ithGraph,1) ...
            = mean(bottomChannelSedThick(bottomChannel));      
        
        % ����ۿ뿡 ���� ������ �β� ��ȭ��
        lowerHillDSedThick = dSedThickByHillslopePerDT(lowerCrossProfileZone,:);
        extEastLowerHillDSedThick(ithGraph,1) ...
            = mean(lowerHillDSedThick(bottomHillslope));
        
        % ��ݾ� �ϻ� ħ����
        lowerChannelDBedrockElev = dBedrockElevByFluvialPerDT(lowerCrossProfileZone,:);
        extEastLowerChannelDBedrockElev(ithGraph,1) ...
            = mean(lowerChannelDBedrockElev(bottomChannel));
        
        % ��õ�� ���� ������ �β� ��ȭ��
        lowerChannelDSedThick = dSedThickByFluvialPerDT(lowerCrossProfileZone,:);
        extEastLowerChannelDSedThick(ithGraph,1) ...
            = mean(lowerChannelDSedThick(bottomChannel));
        
        % ������
        lowerUpliftedHeight = upliftedHeightPerDT(lowerCrossProfileZone,:);
        extEastLowerUpliftedHeight(ithGraph,1) = mean(lowerUpliftedHeight(:));  
        
        % ǳȭ��
        lowerWeatheringRate = weatheringProduct(lowerCrossProfileZone,:);
        extEastLowerChannelWeatheringRate(ithGraph,1) ...
            = mean(mean(lowerWeatheringRate(bottomChannel)));
        extEastLowerHillslopeWeatheringRate(ithGraph,1) ...
            = mean(mean(lowerWeatheringRate(bottomHillslope)));
        
        % ������ ��ݴɷ�
        lowerFluvialTransportCapacity = fluvialTransportCapacity(lowerCrossProfileZone,:);
        extEastLowerFluvialTransportCapacity(ithGraph,1) ...
            = mean(lowerFluvialTransportCapacity(bottomChannel));
        
        %------------------------------------------------------------------
%         % R. ��õ���ܰ
%         if SHOW_GRAPH == SHOW_GRAPH_YES
%         
%         % (A) figure �غ�
%         figure(Hf_17);
%         clf                % figure plot�� ����
%        
%         % (B) ��õ�� ���� �ľ�
%         channelCell ...
%             = (transportMode ~= SOIL_MANTLED_HILLSLOPE) ...
%             & (transportMode ~= BEDROCK_EXPOSED_HILLSLOPE) ...
%             & (transportMode ~= OUTER_BOUNDARY);
% 
%         % (C) �������� �帣�� ��õ�� ���ܰ
%         
%         % a. �������� �帣�� ��õ ��
%         topToBottomChannel = find(channelCell & L == EAST_DRAINAGE);
%         
%         % b. ���� ������ ��õ ���� �ִ� ��츸 ���ܰ�� �ۼ���
%         [chanCellsNo,tmp] = size(topToBottomChannel);
%         if chanCellsNo > 0
%             
%             % a) ���� ������ ��õ ���� �����ϴ� ���
%             
%             % (a) ���� ū �ϱ��� ��ǥ
%             
%             % �� ���� ��迡�� ������ ���� ���� �ϱ� ���� X ��ǥ
%             [tmp,pX] = max(bankfullDischarge(Y_MAX,:));
%             pY = Y_MAX;                     % �ϱ� ���� Y ��ǥ
%             
%             % (b) ���ܰ �ʱ�ȭ
%             profile1 = zeros(Y*X,2);
%             distance1 = zeros(Y*X,1);
%             profilePath = false(mRows,nCols);
%             
%             % (c) �ϱ� ���������� ������ ���� ���� �̿� ���� ��ǥ�� �����
%             i = 1;                          % �ϱ��κ����� ���ܰ�� �� ����
%             profile1(i,:) = [pY,pX];        % �ϱ� ���� ��ǥ�� ó���� ���
%             distance1(i) = 0;               % �ϱ��κ����� �Ÿ� [m]
%             isEnd = false;
%             
%             while(isEnd == false)
% 
%                 i = i + 1;                  % ���ܰ�� �� ���� 1 ����
%                 profilePath(pY,pX) = true;  % ������ ��θ� ǥ����
%                 
%                 % 1. �̿� ���� ������ ���� ���� ���� ��ǥ�� ����
%                 
%                 % �¿� ������ �Ǿ��� ���, offsetX ����
%                 if IS_LEFT_RIGHT_CONNECTED == true
%                     
%                     if pX == X_INI
%                         
%                         nbrX = pX + X_INI_OffsetX;        % �̿� �� X ��ǥ �迭
%                         
%                     elseif pX == X_MAX
%                         
%                         nbrX = pX + X_MAX_OffsetX;        % �̿� �� X ��ǥ �迭
%                         
%                     else
%                         
%                         nbrX = pX + offsetX;        % �̿� �� X ��ǥ �迭
%                         
%                     end
%                     
%                 end                         
%                 
%                 nbrY = pY + offsetY;        % �̿� �� Y ��ǥ �迭
% 
%                 nbrIdx = sub2ind([mRows,nCols],nbrY,nbrX);                
%                 
%                 nbrDischarge = bankfullDischarge(nbrIdx); % �̿� �� ���� �迭
%                 nbrProfilePath = profilePath(nbrIdx); % ������ ���
%                 
%                 % �̿� �� ��ǥ, ���� �� �������� ������ ����
%                 nbrInfo = [nbrY,nbrX,nbrDischarge,nbrProfilePath];
%                 
%                 % ������ ��λ� �ִ� ���� �ƴϸ鼭 ������ ���� ū ������ ������
%                 sortedNbrInfo = sortrows(nbrInfo,[4,-3]);
%                 
%                 % �̿� ���� ������ ���� ���� ���� ��ǥ               
%                 newPY = sortedNbrInfo(1,1);
%                 newPX = sortedNbrInfo(1,2);
%                 
%                 % 2. ������ ���� ���� ���� ��õ�̰�, ���� ������ ���Ѵٸ� �̸�
%                 %    ���ܰ�� �����
%                 if transportMode(newPY,newPX) ~= SOIL_MANTLED_HILLSLOPE ...
%                     && transportMode(newPY,newPX) ~= BEDROCK_EXPOSED_HILLSLOPE ...
%                     && L(newPY,newPX) == EAST_DRAINAGE
%                 
%                     % �̿� ������ �Ÿ��� ����
%                     if abs(pY-newPY) == 1 && abs(pX-newPX) == 1
%                         distance1(i) = distance1(i-1) + dX * ROOT2;
%                     else
%                         distance1(i) = distance1(i-1) + dX;
%                     end
% 
%                     % �̿� ���� ��ǥ�� ���ܰ�� �����
%                     pY = newPY;
%                     pX = newPX;
% 
%                     profile1(i,:) = [pY,pX];
%                 
%                 else
%                     
%                     isEnd = true;
%                     
%                 end
% 
%             end
% 
%             % (d) ���ܰ �� �ʿ���� �� ����
%             [tmp,profileEnd] = min(profile1(:,2));  % Null���� ������ ��ġ
%             profile1 = sub2ind([mRows,nCols] ...    % ������������ ��ȯ
%                 ,profile1(1:profileEnd-1,1),profile1(1:profileEnd-1,2));
%             distance1 = distance1(1:profileEnd-1,1);
%         
%             % (e) plot
%             subplot(2,1,1)
%             % ��ݾ� �ϻ� ��
%             plot(distance1,bedrockElev(profile1),'Color','Red','LineWidth',1)
%             hold on
%             % ��ݾ� �ϻ� + ��� ������ �β�
%             plot(distance1,bedrockElev(profile1) + sedimentThick(profile1) ...
%                 ,'Color','Blue','LineWidth',1)
%             % xlim([0 distance1(end)])
%             ylim([0 bedrockElev(profile1(end)) + sedimentThick(profile1(end))]);
%             set(gca,'XDir','reverse')               % �������� X���� �ݴ��!
%             
%         end
%         
%         tmpTitle = [int2str(simulatingTime) 'th East Drainage Longitudinal River Profile'];
%         title(tmpTitle)
%         
%         % (D) ������ �帣�� ��õ�� ���ܰ
%         
%         % a. ������ �帣�� ��õ ��
%         bottomToTopChannel = find(channelCell & L == WEST_DRAINAGE);
%         
%         % b. ���� ������ ��õ ���� �ִ� ��츸 ���ܰ�� �ۼ���
%         [chanCellsNo,tmp] = size(bottomToTopChannel);
%         if chanCellsNo > 0
%             
%             % a) ���� ������ ��õ ���� �����ϴ� ���
%             
%             % (a) ���� ū �ϱ��� ��ǥ
%             
%             % �� ���� ��迡�� ������ ���� ���� �ϱ� ���� X ��ǥ
%             [tmp,pX] = max(bankfullDischarge(Y_INI,:));
%             pY = Y_INI;                     % �ϱ� ���� Y ��ǥ
%             
%             % (b) ���ܰ �ʱ�ȭ
%             profile2 = zeros(Y*X,2);
%             distance2 = zeros(Y*X,1);
%             profilePath = false(mRows,nCols);
%             
%             % (c) �ϱ� ���������� ������ ���� ���� �̿� ���� ��ǥ�� �����
%             i = 1;                          % �ϱ��κ����� ���ܰ�� �� ����
%             profile2(i,:) = [pY,pX];        % �ϱ� ���� ��ǥ�� ó���� ���
%             distance2(i) = 0;               % �ϱ��κ����� �Ÿ� [m]
%             isEnd = false;
%             
%             while(isEnd == false)
% 
%                 i = i + 1;                  % ���ܰ�� �� ���� 1 ����
%                 profilePath(pY,pX) = true;  % ������ ��� ǥ��
%                 
%                 % 1. �̿� ���� ������ ���� ���� ���� ��ǥ�� ����
%                 
%                 % �¿� ������ �Ǿ��� ���, offsetX ����
%                 if IS_LEFT_RIGHT_CONNECTED == true
%                     
%                     if pX == X_INI
%                         
%                         nbrX = pX + X_INI_OffsetX;        % �̿� �� X ��ǥ �迭
%                         
%                     elseif pX == X_MAX
%                         
%                         nbrX = pX + X_MAX_OffsetX;        % �̿� �� X ��ǥ �迭
%                         
%                     else
%                         
%                         nbrX = pX + offsetX;        % �̿� �� X ��ǥ �迭
%                         
%                     end
%                     
%                 end                        
%                 
%                 nbrY = pY + offsetY;        % �̿� �� Y ��ǥ �迭
% 
%                 nbrIdx = sub2ind([mRows,nCols],nbrY,nbrX);                
%                 
%                 nbrDischarge = bankfullDischarge(nbrIdx); % �̿� �� ���� �迭
%                 nbrProfilePath = profilePath(nbrIdx); % �̿� �� ������ ��� ����
%                 
%                 % �̿� �� ��ǥ, ���� �� �������� ������ ����
%                 nbrInfo = [nbrY,nbrX,nbrDischarge,nbrProfilePath];
%                 
%                 % ������ ��λ� �ִ� ���� �ƴϸ鼭 ������ ���� ū ������ ������
%                 sortedNbrInfo = sortrows(nbrInfo,[4 -3]);
%                 
%                 % �̿� ���� ������ ���� ���� ���� ��ǥ               
%                 newPY = sortedNbrInfo(1,1);
%                 newPX = sortedNbrInfo(1,2);
%                 
%                 % 2. ������ ���� ���� ���� ��õ�̰�, ���� ������ ���Ѵٸ� �̸�
%                 %    ���ܰ�� �����
%                 if transportMode(newPY,newPX) ~= SOIL_MANTLED_HILLSLOPE ...
%                     && transportMode(newPY,newPX) ~= BEDROCK_EXPOSED_HILLSLOPE ...
%                     && L(newPY,newPX) == WEST_DRAINAGE
%                 
%                     % �̿� ������ �Ÿ��� ����
%                     if abs(pY-newPY) == 1 && abs(pX-newPX) == 1
%                         distance2(i) = distance2(i-1) + dX * ROOT2;
%                     else
%                         distance2(i) = distance2(i-1) + dX;
%                     end
% 
%                     % �̿� ���� ��ǥ�� ���ܰ�� �����
%                     pY = newPY;
%                     pX = newPX;
% 
%                     profile2(i,:) = [pY,pX];
%                 
%                 else
%                     
%                     isEnd = true;
%                     
%                 end
% 
%             end
% 
%             % (d) ���ܰ �� �ʿ���� �� ����
%             [tmp,profileEnd] = min(profile2(:,2));  % Null���� ������ ��ġ
%             profile2 = sub2ind([mRows,nCols] ...    % ������������ ��ȯ
%                 ,profile2(1:profileEnd-1,1),profile2(1:profileEnd-1,2));
%             distance2 = distance2(1:profileEnd-1,1);
%         
%             % (e) plot
%             subplot(2,1,2)
%             % ��ݾ� �ϻ� ��
%             plot(distance2,bedrockElev(profile2),'Color','Red','LineWidth',1)
%             hold on
%             % ��ݾ� �ϻ� + ��� ������ �β�
%             plot(distance2,bedrockElev(profile2) + sedimentThick(profile2) ...
%                 ,'Color','Blue','LineWidth',1)
%             % xlim([0 distance2(end)])
%             ylim([0 bedrockElev(profile2(end)) + sedimentThick(profile2(end))]);
%             
%         end   
%         
%         tmpTitle = [int2str(simulatingTime) 'th West Drainage Longitudinal River Profile'];
%         title(tmpTitle)
%         
%         end
        
        %------------------------------------------------------------------
        % S. �������� Ư�� �׷���
        
        % (A) ������ ���� ���� ����
        L(Y_TOP_BND,X_INI:X_MAX) = 0;
        L(Y_BOTTOM_BND,X_INI:X_MAX) = 0;       
        eastDrainage = L == EAST_DRAINAGE;
        eastDrainageCellsNo = sum(eastDrainage(:));
        westDrainage = L == WEST_DRAINAGE;
        westDrainageCellsNo = sum(westDrainage(:));
        
        % (B) ��������� �ð���
        endTimeX = firstGraphShowTime + (ithGraph-1) * dGraphShowTime * dT;
        timeX = firstGraphShowTime:dGraphShowTime*dT:endTimeX;
        
        % (C) ��� ���� ��� ���
        facetFlowSlope(isinf(facetFlowSlope)) = NaN;
        
        eastMeanElev(ithGraph) = mean(elev(eastDrainage));
        eastMeanSlope(ithGraph) = nanmean(facetFlowSlope(eastDrainage));
        westMeanElev(ithGraph) = mean(elev(westDrainage));
        westMeanSlope(ithGraph) = nanmean(facetFlowSlope(westDrainage));
        
        % * �׷���
        maxElev = max(max(eastMeanElev(1:ithGraph)) ...
            ,max(westMeanElev(1:ithGraph)));
        maxSlope = max(max(eastMeanSlope(1:ithGraph)) ...
            ,max(westMeanSlope(1:ithGraph)));
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        figure(Hf_18);
        
        subplot(2,1,1)
        [AX,H1,H2] ...
            = plotyy(timeX,eastMeanElev(1:ithGraph) ...
            ,timeX,eastMeanSlope(1:ithGraph),'plot');
        set(get(AX(1),'Ylabel'),'String','Mean Elevation')
        set(get(AX(2),'Ylabel'),'String','Mean Slope')
        set(AX(1),'ylim',[0 maxElev],'xlim',[0 endTimeX])
        set(AX(2),'ylim',[0 maxSlope],'xlim',[0 endTimeX])
        
        % xlabel('Time')
        set(H1,'LineStyle','--')
        set(H2,'LineStyle',':')
        tmpTitle = [int2str(simulatingTime) 'th East Drainage Geomorphic Char.'];
        title(tmpTitle)
        
        subplot(2,1,2)
        [AX,H1,H2] ...
            = plotyy(timeX,westMeanElev(1:ithGraph) ...
            ,timeX,westMeanSlope(1:ithGraph),'plot');
        set(get(AX(1),'Ylabel'),'String','Mean Elevation')
        set(get(AX(2),'Ylabel'),'String','Mean Slope')
        set(AX(1),'ylim',[0 maxElev],'xlim',[0 endTimeX])
        set(AX(2),'ylim',[0 maxSlope],'xlim',[0 endTimeX])
        xlabel('Time')
        set(H1,'LineStyle','--')
        set(H2,'LineStyle',':')        
        tmpTitle = [int2str(simulatingTime) 'th West Drainage Geomorphic Char.'];
        title(tmpTitle)
        
        end
        
        % (D) �ϰ�е�
        drainageNetwork = bedrockChan | alluvialChan;
        eastDrainageDensity = sum(drainageNetwork(eastDrainage)) * dX ...
            / (eastDrainageCellsNo * dX * dX);
        westDrainageDensity = sum(drainageNetwork(westDrainage)) * dX ...
            / (westDrainageCellsNo * dX * dX);
        
        % (E) ���ȯ�� ����
        eastSoilMantledHillRatio ...
            = sum(soilMantledHill(eastDrainage)) / eastDrainageCellsNo;
        westSoilMantledHillRatio ...
            = sum(soilMantledHill(westDrainage)) / westDrainageCellsNo;
        
        eastBedrockExposedHillRatio ...
            = sum(bedrockExposedHill(eastDrainage)) / eastDrainageCellsNo;
        westBedrockExposedHillRatio ...
            = sum(bedrockExposedHill(:)) / westDrainageCellsNo;
        
        eastAlluvialChanRatio ...
            = sum(alluvialChan(eastDrainage)) / eastDrainageCellsNo;
        westAlluvialChanRatio ...
            = sum(alluvialChan(westDrainage)) / westDrainageCellsNo;
        
        eastBedrockChanRatio ...
            = sum(bedrockChan(eastDrainage)) / eastDrainageCellsNo;
        westBedrockChanRatio ...
            = sum(bedrockChan(westDrainage)) / westDrainageCellsNo;        
        
        % (D) �������� Ư��
        eastMeanSedimentThick(ithGraph) ...
            = mean(sedimentThick(eastDrainage));
        eastMeanWeatheringProduct(ithGraph) ...
            = mean(weatheringProduct(eastDrainage));
        westMeanSedimentThick(ithGraph) ...
            = mean(sedimentThick(westDrainage));
        westMeanWeatheringProduct(ithGraph) ...
            = mean(weatheringProduct(westDrainage));        
        
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        % * �׷���
        maxSedThick = max(max(eastMeanSedimentThick(1:ithGraph)) ...
            ,max(westMeanSedimentThick(1:ithGraph)));
        maxWeathering = max(max(eastMeanWeatheringProduct(1:ithGraph)) ...
            ,max(westMeanWeatheringProduct(1:ithGraph)));
        
        figure(Hf_19);
        
        subplot(2,1,1);
        [AX,H1,H2] ...
            = plotyy(timeX,eastMeanSedimentThick(1:ithGraph) ...
            ,timeX,eastMeanWeatheringProduct(1:ithGraph),'plot');
        set(get(AX(1),'Ylabel'),'String','Mean Sediment Thickness')
        set(get(AX(2),'Ylabel'),'String','Mean Weathering Product')
        % xlabel('Time')
        set(H1,'LineStyle','--')
        set(H2,'LineStyle',':')
        set(AX(1),'ylim',[0 maxSedThick],'xlim',[0 endTimeX])
        set(AX(2),'ylim',[0 maxWeathering],'xlim',[0 endTimeX])
        tmpTitle = [int2str(simulatingTime) 'th East Drainage Material Char'];
        title(tmpTitle)
        
        subplot(2,1,2);
        [AX,H1,H2] ...
            = plotyy(timeX,westMeanSedimentThick(1:ithGraph) ...
            ,timeX,westMeanWeatheringProduct(1:ithGraph),'plot');
        set(get(AX(1),'Ylabel'),'String','Mean Sediment Thickness')
        set(get(AX(2),'Ylabel'),'String','Mean Weathering Product')
        xlabel('Time')
        set(H1,'LineStyle','--')
        set(H2,'LineStyle',':')
        set(AX(1),'ylim',[0 maxSedThick],'xlim',[0 endTimeX])
        set(AX(2),'ylim',[0 maxWeathering],'xlim',[0 endTimeX])
        tmpTitle = [int2str(simulatingTime) 'th West Drainage Material Char'];
        title(tmpTitle)
        
        end
        
        %------------------------------------------------------------------
        % T. ������������ Ư��
        
        % (A) ���� ��� ħ���� [m^3/m^2 East Drainage]
        
        % a. ����ۿ뿡 ���� ��� ħ����
        eastMeanHillslopeErosionRate ...
            = sum(dSedThickByHillslopePerDT(Y_BOTTOM_BND,:)) / eastDrainageCellsNo;
        westMeanHillslopeErosionRate ...
            = sum(dSedThickByHillslopePerDT(Y_TOP_BND,:)) / westDrainageCellsNo;
        
        % b. ���� ����ۿ뿡 ���� ��� ħ����
        eastMeanRapidMassErosionRate ...
            = sum(dSedThickByRapidMassPerDT(Y_BOTTOM_BND,:)) / eastDrainageCellsNo;
        westMeanRapidMassErosionRate ...
            = sum(dSedThickByRapidMassPerDT(Y_TOP_BND,:)) / westDrainageCellsNo;
        
        % c. ��õ�� ���� ��� ħ����
        eastFluvialOutputFluxAtBnd = dSedThickByFluvialPerDT(Y_BOTTOM_BND,:);
        westFluvialOutputFluxAtBnd = dSedThickByFluvialPerDT(Y_TOP_BND,:);
        
        % * ����: eastFluvialOutputFluxAtBnd ��ü�� �� �������� ���� ���̹Ƿ�
        %   ���� ��հ��� ���ϱ� ���ؼ��� �� ������ ������ ��
        eastMeanFluvialErosionRate ...
            = sum(eastFluvialOutputFluxAtBnd) / eastDrainageCellsNo;
        westMeanFluvialErosionRate ...
            = sum(westFluvialOutputFluxAtBnd) / westDrainageCellsNo;        
        
        % d. ���� ��� ħ����
        eastMeanErosionRate(ithGraph) = eastMeanHillslopeErosionRate ...
            + eastMeanRapidMassErosionRate + eastMeanFluvialErosionRate;
        
        westMeanErosionRate(ithGraph) = westMeanHillslopeErosionRate ...
            + westMeanRapidMassErosionRate + westMeanFluvialErosionRate;        
        
        % (B) ���� ��� ������ [m/East Drainage]
        upliftedHeight(Y_INI:Y_MAX,X_INI:X_MAX) ...
            = (meanUpliftRateSpatialDistribution(Y_INI:Y_MAX,X_INI:X_MAX) ...
            ./ meanUpliftRateAtUpliftAxis) ...
            .* upliftRateTemporalDistribution(ithTimeStep);
        eastMeanUpliftedHeight(ithGraph) = mean(upliftedHeight(eastDrainage));
        westMeanUpliftedHeight(ithGraph) = mean(upliftedHeight(westDrainage));
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        % (C) �׷��� �� ����
        maxErosionRate ...
            = max(max(eastMeanErosionRate(1:ithGraph)) ...
            ,max(max(westMeanErosionRate(1:ithGraph))));
        
        if maxErosionRate == 0
            maxErosionRate = 1 * 10^-10;
        end
        
        maxUpliftedHeight ...
            = max(max(eastMeanUpliftedHeight(1:ithGraph)) ...
            ,max(max(westMeanUpliftedHeight(1:ithGraph))));
        
        maxY = max(maxErosionRate,maxUpliftedHeight);
        
        % (D) �׷���
        figure(Hf_20);
        
        subplot(2,1,1);
        [AX,H1,H2] ...
            = plotyy(timeX,eastMeanErosionRate(1:ithGraph) ...
            ,timeX,eastMeanUpliftedHeight(1:ithGraph),'plot');
        set(get(AX(1),'Ylabel'),'String','Mean Erosion Rate')
        set(get(AX(2),'Ylabel'),'String','Mean Uplifted Height')
        % xlabel('Time')
        set(H1,'LineStyle','--')
        set(H2,'LineStyle',':')
        set(AX(1),'ylim',[0 maxY],'xlim',[0 endTimeX])
        set(AX(2),'ylim',[0 maxY],'xlim',[0 endTimeX])
        tmpTitle = [int2str(simulatingTime) 'th East Drainage Process Char'];
        title(tmpTitle)
        
        subplot(2,1,2);
        [AX,H1,H2] ...
            = plotyy(timeX,westMeanErosionRate(1:ithGraph) ...
            ,timeX,westMeanUpliftedHeight(1:ithGraph),'plot');
        set(get(AX(1),'Ylabel'),'String','Mean Erosion Rate')
        set(get(AX(2),'Ylabel'),'String','Mean Uplifted Height')
        set(AX(1),'ylim',[0 maxY],'xlim',[0 endTimeX])
        set(AX(2),'ylim',[0 maxY],'xlim',[0 endTimeX])       
        xlabel('Time')
        set(H1,'LineStyle','--')
        set(H2,'LineStyle',':')        
        tmpTitle = [int2str(simulatingTime) 'th West Drainage Process Char'];
        title(tmpTitle)
        
        end
        
        % (E) ���¹߻��� ����
        rapidMassOccured = (dSedThickByRapidMassPerDT < 0) ...
            | (dBedrockElevByRapidMassPerDT < 0);
        eastRapidMassFreq = sum(rapidMassOccured(eastDrainage));
        westRapidMassFreq = sum(rapidMassOccured(westDrainage));
        
        %------------------------------------------------------------------
        % U. ������[m] ����
        % * ����: ���� �ϵ� �� �ϻ� ������[m^3/ED] ������ ������ ������ ����
        
        % a. ������ ���� ����
        eastDBedrockElevByFluvial ...             % ��ݾ� �ϻ����κ����� ����
            = mean(dBedrockElevByFluvialPerDT(eastDrainage));        
        eastMeanDBedrockElevByRapidMass ...     % �ϼ��ر��� ���� ����
            = mean(dBedrockElevByRapidMassPerDT(eastDrainage));        
        eastMeanOldSedimentThick ...            % �ʱ� ������ �β�
            = mean(sedimentThick(eastDrainage));

        eastSedimentNewInput ...
            = eastMeanWeatheringProduct(ithGraph) ...
            - eastDBedrockElevByFluvial ...
            - eastMeanDBedrockElevByRapidMass;
        
        eastSedimentInput ...
            = eastSedimentNewInput + eastMeanOldSedimentThick;
        
        westDBedrockElevByFluvial ...             % ��ݾ� �ϻ����κ����� ����
            = mean(dBedrockElevByFluvialPerDT(westDrainage));        
        westMeanDBedrockElevByRapidMass ...     % �ϼ��ر��� ���� ����
            = mean(dBedrockElevByRapidMassPerDT(westDrainage));        
        westMeanOldSedimentThick ...            % �ʱ� ������ �β�
            = mean(sedimentThick(westDrainage));

        westSedimentNewInput ...
            = westMeanWeatheringProduct(ithGraph) ...
            - westDBedrockElevByFluvial ...
            - westMeanDBedrockElevByRapidMass;
        
        westSedimentInput ...
            = westSedimentNewInput + westMeanOldSedimentThick;
        
        % b. ������ ���� ����
        eastMeanNextSedimentThick ...   % ���� ������ �β�
            = mean(sedimentThick(eastDrainage));       
        
        eastRemovedSedimentOutput ...
            = eastMeanFluvialErosionRate ...
            + eastMeanHillslopeErosionRate ...
            + eastMeanRapidMassErosionRate;
        
        eastSedimentOutput ...
            = eastRemovedSedimentOutput + eastMeanNextSedimentThick;
        
        westMeanNextSedimentThick ...   % ���� ������ �β�
            = mean(sedimentThick(westDrainage));       
        
        westRemovedSedimentOutput ...
            = westMeanFluvialErosionRate ...
            + westMeanHillslopeErosionRate ...
            + westMeanRapidMassErosionRate;
        
        westSedimentOutput ...
            = westRemovedSedimentOutput + westMeanNextSedimentThick;
        
        % c. ������ ����: 0 �� �Ǿ�� �� 
        eastSedimentBudget = eastSedimentInput - eastSedimentOutput;        
        westSedimentBudget = westSedimentInput - westSedimentOutput;
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
        
        % (C) ��� ���
        figure(Hf_21)
        clf
        set(gcf,'Color','white');               % ����ȭ�� �Ͼ� ��
        mTextBox = uicontrol('style','text');   % "text" uicontrol ����
        set(mTextBox,'Units','characters' ...   % ũ�� ���� 'characters'
            ,'FontSize',8 ...                  % ��Ʈ ũ��
            ,'Position',[4,0,60,21])           % �ؽ�Ʈ ���� ��ġ �� ũ��
        set(mTextBox,'String' ...
            ,{sprintf('East Drainage Sediment Budget: %6.3f',eastSedimentBudget) ...
            ,sprintf('-------------------------------------------------------------------') ...
            ,sprintf('Old Sed[m]: %6.3f              / Current Sediment[m]: %6.3f' ...
            ,eastMeanOldSedimentThick,eastMeanNextSedimentThick) ...
            ,sprintf('Weathering[p]: %6.1f         /                                     ' ...
            ,eastMeanWeatheringProduct(ithGraph) / eastSedimentNewInput * 100) ...
            ,sprintf('Fluvial dBedElev[p]: %6.1f / Fluvial Erosio[p]n: %6.1f' ...
            ,- eastDBedrockElevByFluvial / eastSedimentNewInput * 100 ...
            ,eastMeanFluvialErosionRate / eastRemovedSedimentOutput * 100) ...
            ,sprintf('RapidMass dBedElev[p]: %6.1f / RapidMass Erosion[p]: %6.1f' ...
            ,- eastMeanDBedrockElevByRapidMass / eastSedimentNewInput * 100 ...
            ,eastMeanRapidMassErosionRate / eastRemovedSedimentOutput * 100) ...
            ,sprintf('                                              / SlowMass Erosion[p]: %6.1f' ...
            ,eastMeanHillslopeErosionRate / eastRemovedSedimentOutput * 100) ...
            ,sprintf('-------------------------------------------------------------------') ...
            ,sprintf('New Input[m]: %9.6f     / Total Output[m]: %9.6f' ...
            ,eastSedimentNewInput,eastRemovedSedimentOutput) ...
            ,sprintf('==================================================') ...
            ,sprintf('West Drainage Sediment Budget: %6.3f',westSedimentBudget) ...
            ,sprintf('-------------------------------------------------------------------') ...
            ,sprintf('Old Sed[m]: %6.3f              / Current Sediment[m]: %6.3f' ...
            ,westMeanOldSedimentThick,westMeanNextSedimentThick) ...
            ,sprintf('Weathering[p]: %6.1f         /                                     ' ...
            ,westMeanWeatheringProduct(ithGraph) / westSedimentNewInput * 100 ) ...
            ,sprintf('Fluvial dBedElev[p]: %6.1f / Fluvial Erosion[p]: %6.1f' ...
            ,- westDBedrockElevByFluvial / westSedimentNewInput * 100 ...
            ,westMeanFluvialErosionRate / westRemovedSedimentOutput * 100 ) ...
            ,sprintf('RapidMass dBedElev[p]: %6.1f / RapidMass Erosion[p]: %6.1f' ...
            ,-westMeanDBedrockElevByRapidMass / westSedimentNewInput * 100 ...
            ,westMeanRapidMassErosionRate / westRemovedSedimentOutput * 100) ...
            ,sprintf('                                              / SlowMass Erosion[p]: %6.f' ...
            ,westMeanHillslopeErosionRate / westRemovedSedimentOutput * 100) ...
            ,sprintf('-------------------------------------------------------------------') ...
            ,sprintf('New Input[m]: %9.6f     / Total Output[m]: %9.6f' ...
            ,westSedimentNewInput,westRemovedSedimentOutput)})
        % �ؽ�Ʈ ���� ���� figure ���� �����ϰ� ������
        colorOfFigureWindow = get(Hf_21,'Color');
        set(mTextBox,'BackgroundColor',colorOfFigureWindow)
        
        end
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
            
        % (B) �ϵ� �� �ϻ� ������ ����
        figure(Hf_22);
        imagesc([0.5*dX dX distanceX-0.5*dX] ...
            ,[0.5*dX dX distanceY-0.5*dX] ...
            ,chanBedSedBudget(Y_INI:Y_MAX,X_INI:X_MAX));
        set(gca,'DataAspectRatio',[1 1 1])
        colorbar
        tmpTitle = [int2str(simulatingTime) 'th chanBedSed Budget'];
        title(tmpTitle)      
        
        end
        
        %------------------------------------------------------------------
        % V. i��° (��Ʈ������) ��õ ����
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
        
        figure(Hf_23);

        % calculate flow accumulation and direction
        [A,M] = wflowacc(arrayXForGraph,arrayYForGraph,elev(Y_INI:Y_MAX,X_INI:X_MAX),'type','single');
        % let's simply assume that channels start where A is larger than 100;
        W = A>100;
        % and calculate the strahler stream order
        [S,nodes] = streamorder(M,W);
        % and visualize it
        subplot(1,2,1); 
        pcolor(arrayXForGraph,arrayYForGraph,+W); axis image; shading flat;
        set(gca,'YDir','reverse')
        colorbar
        title('Stream Network')
        subplot(1,2,2);
        pcolor(arrayXForGraph,arrayYForGraph,S); axis image; shading flat;
        set(gca,'YDir','reverse')
        colorbar
        hold on
        plot(arrayXForGraph(nodes),arrayYForGraph(nodes),'ks','MarkerFaceColor','g')
        title('Strahler Stream Order')
        
        end
       
        %------------------------------------------------------------------
        % W. i ��° ���Ҹ�Ʈ�� �
        
        if SHOW_GRAPH == SHOW_GRAPH_YES
        
        figure(Hf_24);
        
        hypsometry(elev(Y_INI:Y_MAX,X_INI:X_MAX),20,[1 1],'ro-',[2 2],Hf_24,totalGraphShowTimesNo,ithGraph);
        
        end
        
        % ������ �������� �ֿ� �������� �����
        % ū �������� 2���� �ֿ� �������� �����
        if mod(ithGraph,EXTRACT_INTERVAL) == 0
            
            ithExtractTime = ithExtractTime + 1;
            
            extSedimentThick(:,:,ithExtractTime+1) = sedimentThick;
            extBedrockElev(:,:,ithExtractTime+1) = bedrockElev;
            extWeatheringProduct(:,:,ithExtractTime) = weatheringProduct;
            extDSedThickByHillslopePerDT(:,:,ithExtractTime) = dSedThickByHillslopePerDT;
            extDSedThickByRapidMassPerDT(:,:,ithExtractTime) = dSedThickByRapidMassPerDT;
            extDBedrockElevByRapidMassPerDT(:,:,ithExtractTime) = dBedrockElevByRapidMassPerDT;
            extDSedThickByFluvialPerDT(:,:,ithExtractTime) = dSedThickByFluvialPerDT;
            extDBedrockElevByFluvialPerDT(:,:,ithExtractTime) = dBedrockElevByFluvialPerDT;
            extChanBedSedBudget(:,:,ithExtractTime) = chanBedSedBudget;
            extUpslopeArea(:,:,ithExtractTime) = upslopeArea;
            extTransportMode(:,:,ithExtractTime) = transportMode;
            extFacetFlowSlope(:,:,ithExtractTime) = facetFlowSlope;
            
        end
        
        % 1����
        extEastDrainageDensity(ithGraph,:) = eastDrainageDensity;
        extWestDrainageDensity(ithGraph,:) = westDrainageDensity;
        extEastSoilMantledHillRatio(ithGraph,:) = eastSoilMantledHillRatio;
        extWestSoilMantledHillRatio(ithGraph,:) = westSoilMantledHillRatio;
        extEastBedrockExposedHillRatio(ithGraph,:) = eastBedrockExposedHillRatio;
        extWestBedrockExposedHillRatio(ithGraph,:) = westBedrockExposedHillRatio;
        extEastAlluvialChanRatio(ithGraph,:) = eastAlluvialChanRatio;
        extWestAlluvialChanRatio(ithGraph,:) = westAlluvialChanRatio;
        extEastBedrockChanRatio(ithGraph,:) = eastBedrockChanRatio;
        extWestBedrockChanRatio(ithGraph,:) = westBedrockChanRatio;
        extEastRapidMassFreq(ithGraph,:) = eastRapidMassFreq;
        extWestRapidMassFreq(ithGraph,:) = westRapidMassFreq;
        
    end
    
end

% ����� �ֿ� �������� ����ü�� ��ȯ��
majorOutputs = struct('sedimentThick',extSedimentThick ...
    ,'bedrockElev',extBedrockElev ...
    ,'weatheringProduct',extWeatheringProduct ...
    ,'dSedThickByHillslopePerDT',extDSedThickByHillslopePerDT ...
    ,'dSedThickByRapidMassPerDT',extDSedThickByRapidMassPerDT ...
    ,'dBedrockElevByRapidMassPerDT',extDBedrockElevByRapidMassPerDT ...
    ,'dSedThickByFluvialPerDT',extDSedThickByFluvialPerDT ...
    ,'dBedrockElevByFluvialPerDT',extDBedrockElevByFluvialPerDT ...
    ,'chanBedSedBudget',extChanBedSedBudget ...
    ,'facetFlowSlope',extFacetFlowSlope ...
    ,'upslopeArea',extUpslopeArea ...
    ,'transportMode',extTransportMode ...
    ,'eastMeanElev',eastMeanElev ...
    ,'westMeanElev',westMeanElev ...
    ,'eastMeanSlope',eastMeanSlope ...
    ,'westMeanSlope',westMeanSlope ...
    ,'eastMeanErosionRate',eastMeanErosionRate ...
    ,'westMeanErosionRate',westMeanErosionRate ...
    ,'eastSedimentThick',eastMeanSedimentThick ...
    ,'westSedimentThick',westMeanSedimentThick ...
    ,'eastWeatheringProduct',eastMeanWeatheringProduct ...
    ,'westWeatheringProduct',westMeanWeatheringProduct ...
    ,'eastUpliftedHeight',eastMeanUpliftedHeight ...
    ,'westUpliftedHeight',westMeanUpliftedHeight ...
    ,'eastDrainageDensity',extEastDrainageDensity ...
    ,'westDrainageDensity',extWestDrainageDensity ...
    ,'eastSoilMantledHillRatio',extEastSoilMantledHillRatio ...
    ,'westSoilMantledHillRatio',extWestSoilMantledHillRatio ...
    ,'eastBedrockExposedHillRatio',extEastBedrockExposedHillRatio ...
    ,'westBedrockExposedHillRatio',extWestBedrockExposedHillRatio ...
    ,'eastAlluvialChanRatio',extEastAlluvialChanRatio ...
    ,'westAlluvialChanRatio',extWestAlluvialChanRatio ...
    ,'eastBedrockChanRatio',extEastBedrockChanRatio ...
    ,'westBedrockChanRatio',extWestBedrockChanRatio ...
    ,'eastRapidMassFreq',extEastRapidMassFreq ...
    ,'westRapidMassFreq',extWestRapidMassFreq ...
    ,'eastUpperHillRegolithThick',extEastUpperHillRegolithThick ...
    ,'eastMiddleHillRegolithThick',extEastMiddleHillRegolithThick ...
    ,'eastBottomHillRegolithThick',extEastBottomHillRegolithThick ...
    ,'eastUpperChannelSedThick',extEastUpperChannelSedThick ...
    ,'eastMiddleChannelSedThick',extEastMiddleChannelSedThick ...
    ,'eastBottomChannelSedThick',extEastBottomChannelSedThick ...  
    ,'eastUpperHillDSedThick',extEastUpperHillDSedThick ...  
    ,'eastMiddleHillDSedThick',extEastMiddleHillDSedThick ...  
    ,'eastLowerHillDSedThick',extEastLowerHillDSedThick ...  
    ,'eastUpperChannelDBedrockElev',extEastUpperChannelDBedrockElev ...  
    ,'eastMiddleChannelDBedrockElev',extEastMiddleChannelDBedrockElev ...  
    ,'eastLowerChannelDBedrockElev',extEastLowerChannelDBedrockElev ...  
    ,'eastUpperChannelDSedThick',extEastUpperChannelDSedThick ...  
    ,'eastMiddleChannelDSedThick',extEastMiddleChannelDSedThick ...  
    ,'eastLowerChannelDSedThick',extEastLowerChannelDSedThick ...
    ,'eastUpperUpliftedHeight',extEastUpperUpliftedHeight ...  
    ,'eastMiddleUpliftedHeight',extEastMiddleUpliftedHeight ...  
    ,'eastLowerUpliftedHeight',extEastLowerUpliftedHeight ... 
    ,'eastUpperChannelWeatheringRate',extEastUpperChannelWeatheringRate ...  
    ,'eastMiddleChannelWeatheringRate',extEastMiddleChannelWeatheringRate ...  
    ,'eastLowerChannelWeatheringRate',extEastLowerChannelWeatheringRate ...
    ,'eastUpperHillslopeWeatheringRate',extEastUpperHillslopeWeatheringRate ...  
    ,'eastMiddleHillslopeWeatheringRate',extEastMiddleHillslopeWeatheringRate ...  
    ,'eastLowerHillslopeWeatheringRate',extEastLowerHillslopeWeatheringRate ...
    ,'eastUpperFluvialTransportCapacity',extEastUpperFluvialTransportCapacity ...
    ,'eastMiddleFluvialTransportCapacity',extEastMiddleFluvialTransportCapacity ...
    ,'eastLowerFluvialTransportCapacity',extEastLowerFluvialTransportCapacity ...
    ,'Y',Y,'X',X,'Y_INI',Y_INI,'Y_MAX',Y_MAX,'X_INI',X_INI,'X_MAX',X_MAX ...
    ,'upperCrossProfileY',upperCrossProfileY ...
    ,'middleCrossProfileY',middleCrossProfileY ...
    ,'lowerCrossProfileY',lowerCrossProfileY ...
    ,'dX',dX,'dT',dT,'WRITE_INTERVAL',WRITE_INTERVAL ...
    ,'EXTRACT_INTERVAL',EXTRACT_INTERVAL,'GRAPH_INTERVAL',GRAPH_INTERVAL ...
    ,'totalExtractTimesNo',totalExtractTimesNo ...
    ,'totalGraphShowTimesNo',totalGraphShowTimesNo);        

% 2) �α� ������ ����Ѵ�.
logMessage = fileread(OUTPUT_FILE_LOG_PATH);
fprintf(logMessage);

%--------------------------------------------------------------------------
% ��� ��� ������ �ݴ´�.
fclose(FID_WEATHER);
fclose(FID_SEDTHICK);
fclose(FID_BEDROCKELEV);
fclose(FID_dSEDTHICK_BYHILLSLOPE);
fclose(FID_CHANBEDSEDBUDGET);
fclose(FID_dSEDTHICK_BYFLUVIAL);
fclose(FID_dBEDROCKELEV_BYFLUVIAL);
fclose(FID_dSEDTHICK_BYRAPIDMASS);
fclose(FID_dBEDROCKELEV_BYRAPIDMASS);
fclose(FID_LOG);