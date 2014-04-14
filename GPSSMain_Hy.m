% =========================================================================
%> @section INTRO GPSS main
%>
%> - �����ð��Ը��� �����ߴ��� ��ǻ�� �󿡼� �����ϴ� ���α׷�.
%>  - �Է� ������ �о���̰� �̸� ���� �پ��� ���������ۿ����� ���� �����Ӽ���
%>    ��ȭ�� ����ϴ� ���Լ��μ� �پ��� ���Լ����� ȣ����.
%> - ���α׷��� : GPSS(Geomorphological Process System Simulator)
%> - �ۼ��� : �� �� ��
%> - ���� �ۼ��� : 2011-08-19
%>
%> - Histroy
%>  - 2011-10-13
%>   - ��õ �������� ��Ģ���κ��� ���� ����
%>  - 2011-08-19
%>   - ��� ������ ��ǥ����� ���� �����̵��� ������
%>  - 2010-12-21
%>   - RapidMassMovement �Լ��� Ȱ�� �߻�Ȯ�� ������ ������.
%>  - 2010-12-21
%>   - ���ڱ� GPSS �Լ��� �ߴܵǴ��� ���� ������ ���Ͽ� �̾ ������ ��
%>     �ֵ��� �ϱ����� �����Ǳ� ������ ������ �β��� �о� ����. �̿� ���Ҿ� ����
%>     ����� ���� �ð��� �ľ��ϰ� ���ĺ��� ������ �� �ֵ��� ������.
%>  - 2010-09-28
%>   - RapidMassMovement �Լ��� ���� �ӵ��� ����ϱ� ���� CollapseMex.c�� ������.
%>
%> - �߰�����
%>  - �� �ڵ��� �������� Johnson (2002)�� ������ ǥ�� ��õ�� ������, ������ ����.
%> "1. > 1) > (1) > A. > A) > (A) > a. > a) > (a)"
%>
%> @callgraph
%> @callergraph
%> @version 1.82
%> @see FluvialProcess(), AccumulateUpstreamFlow(), ProcessSink(),
%>      RapidMassMovement(), CalcSDSFlow(), AdjustBoundary(),
%>      CalcInfinitiveFlow(), DefineUpriftRateDistribution(),
%>      EstimateSubDT(), HillslopeProcess(), LoadParameterValues(),
%>      MakeInitialGeomorphology(), RockWeathering(), Uplift()
%>
%> @attention Copyright(c). 2011. ������. All rights reserved.
%> - �������� �������� �̿��� ��쿡 ���� ����� ������.
%> - �ڼ��� ������ ������(email : cyberzen.byun At gmail.com)���� ���� �ٶ�.
%> 
%> @retval sedThick.txt                     : ������ �β� [m]
%> @retval bedrockElev.txt                  : ��ݾ� �� [m]
%> @retval weatherProduct.txt               : ǳȭ�� [m/dT]
%> @retval dSedThickByHillslope.txt         : ����ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
%> @retval chanBedSedBudget.txt             : �ϵ� �� ������ ���� [m^3/dT]
%> @retval dSedThickByFluvial.txt           : ��õ�ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
%> @retval dBedrockElevByFluvial.txt        : ��õ�ۿ뿡 ���� ��ݾ� �� ��ȭ�� [m^3/m^2 dT]
%> @retval dSedThickByRapidMassmove.txt     : Ȱ���� ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
%> @retval dBedrockElevByRapidMassmove.txt  : Ȱ���� ���� ��ݾ� �� ��ȭ�� [m^3/m^2 dT]
%> @retval log.txt                          : GPSS ���� ������ ��Ȳ ���
%>
%> @param parameterValuesFile               : GPSS �Լ��� �Է����ڷ� �ʱ� �Է��ڷḦ �����ϰ� �ִ� ���� �̸�
% =========================================================================
function GPSSMain_Hy(parameterValuesFile)

%--------------------------------------------------------------------------
% GPSS 2D ����
clc;
fprintf('\n*************** GPSS 2D Start ***************\n');
fprintf('Made by Jongmin Byun (Post-doctoral researcher, Department of Geography Education, Korea Univ.)\n');
fprintf('Source download at Blog (http://www.byunjongmin.net)\n');
startedTime = clock; % ���� �ð� ���

% ������� ���� ���͸��� ��� ������ �����ϰ� �߿��� �ʱ� �������� �Է�
% * ���� : �Է��� ���� ���͸��� ����� ���� ���͸��� ���е�. ����� ����
%   ���͸����� ���� ���͸��� ������ �� ����.

% ���͸� �̸� ���
DATA_DIR = 'data';      % ����� ������ �����ϴ� �ֻ��� ���͸�
INPUT_DIR = 'input';    % �Է� ������ ����Ǵ� ���͸�
OUTPUT_DIR = 'output';  % ��� ������ ������ ���͸�

% ���͸� ��� ���
INPUT_DIR_PATH = fullfile(DATA_DIR,INPUT_DIR);
OUTPUT_DIR_PATH = fullfile(DATA_DIR,OUTPUT_DIR);

%--------------------------------------------------------------------------
% AnalyseResult �Լ��� ������ �κ�

% ��� ���� ��� : ���� ����� ����ϴ� ����
OUTPUT_FILE_SEDTHICK ...                % i��° ������ �β� [m]
    = 'sedThick.txt';
OUTPUT_FILE_BEDROCKELEV ...             % i��° ��ݾ� �� [m]
    = 'bedrockElev.txt';
OUTPUT_FILE_WEATHER ...                 % ǳȭ�� [m/dT]
    = 'weatherProduct.txt';
OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE ...   % ����ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
    = 'dSedThickByHillslope.txt';
OUTPUT_FILE_CHANBEDSEDBUDGET ...        % �ϵ� �� ������ ���� [m^3/dT]
    = 'chanBedSedBudget.txt';
OUTPUT_FILE_dSEDTHICK_BYFLUVIAL ...     % ��õ�ۿ뿡 ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
    = 'dSedThickByFluvial.txt';
OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL ...  % ��õ�ۿ뿡 ���� ��ݾ� �� ��ȭ�� [m^3/m^2 dT]
    = 'dBedrockElevByFluvial.txt';
OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS ...   % ���� �Ž������Ʈ�� ���� ������ �β� ��ȭ�� [m^3/m^2 dT]
    = 'dSedThickByRapidMassmove.txt';
OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS ... % ���� �Ž������Ʈ�� ���� ��ݾ� �� ��ȭ�� [m^3/m^2 dT]
    = 'dBedrockElevByRapidMassmove.txt';
OUTPUT_FILE_LOG ...                     % GPSS 2D ���� ������ ��Ȳ ���
    = 'log.txt';

% �߿��� �ʱ� �������� �Է���
INPUT_FILE_PARAM_PATH ...   % �Է� ���� ��� ���
    = fullfile(INPUT_DIR_PATH,parameterValuesFile);
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
OUTPUT_FILE_SEDTHICK_PATH ...
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

% ���� ������ �����
FID_SEDTHICK = fopen(OUTPUT_FILE_SEDTHICK_PATH,'a');
FID_BEDROCKELEV = fopen(OUTPUT_FILE_BEDROCKELEV_PATH,'a');
FID_WEATHER = fopen(OUTPUT_FILE_WEATHER_PATH,'a');
FID_dSEDTHICK_BYHILLSLOPE = fopen(OUTPUT_FILE_dSEDTHICK_BYHILLSLOPE_PATH,'a');
FID_CHANBEDSEDBUDGET = fopen(OUTPUT_FILE_CHANBEDSEDBUDGET_PATH,'a');
FID_dSEDTHICK_BYFLUVIAL = fopen(OUTPUT_FILE_dSEDTHICK_BYFLUVIAL_PATH,'a');
FID_dBEDROCKELEV_BYFLUVIAL = fopen(OUTPUT_FILE_dBEDROCKELEV_BYFLUVIAL_PATH,'a');
FID_dSEDTHICK_BYRAPIDMASS = fopen(OUTPUT_FILE_dSEDTHICK_BYRAPIDMASS_PATH,'a');
FID_dBEDROCKELEV_BYRAPIDMASS = fopen(OUTPUT_FILE_dBEDROCKELEV_BYRAPIDMASS_PATH,'a');
FID_LOG = fopen(OUTPUT_FILE_LOG_PATH,'a');

%--------------------------------------------------------------------------
% ��� �� ���� �ʱ�ȭ

[bedrockElev ...    % �ʱ� ��ݾ� ��
,sedimentThick ...
,Y ...              % (����� �ʱ� ������ �ҷ��� ���) Y ��ǥ
,X] ...             % (����� �ʱ� ������ �ҷ��� ���) X ��ǥ
    = MakeInitialGeomorphology(Y,X,dX,PLANE_ANGLE ...
    ,INPUT_DIR_PATH,OUTPUT_SUBDIR_PATH ...
    ,INIT_BEDROCK_ELEV_FILE,initSedThick,INIT_SED_THICK_FILE);

[mRows ...          % �� (�ܰ� ��� ����) ���� �� ����
,nCols] ...         % �� (�ܰ� ��� ����) ���� �� ����
    = size(bedrockElev);

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

bankfullTime = ceil(bankfullTime / timeWeight); % �پ�� �������� ���ӱ�

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
% �α� ���Ͽ� ���

fprintf(FID_LOG,'%i\n%i\n',mRows,nCols);    % (�ܰ� ��� ����) ��, �� ���
fprintf(FID_LOG, ...                        % GPSS 2D ���� �ð� ���
    'GPSS 2D started time : %i[year] %i[month] %i[day] %i[hr] %i[min] %f[sec]\n' ...
    ,startedTime);
fprintf(FID_BEDROCKELEV,'%f\n',bedrockElev);    % �ʱ� ��ݾ� �� ���
fprintf(FID_SEDTHICK,'%f\n',sedimentThick);     % �ʱ� ������ �β� ���

% ��� ������ ����� ���
fprintf(FID_LOG,'(Hillslope Process)    Diffusion Coefficient (kmd):    %f\n',kmd);
fprintf(FID_LOG,'(Fluvial Process)  Transport Capacity Eq. Coefficient (kfa):   %f\n',kfa);
fprintf(FID_LOG,'(Fluvial Process)  Transport Capacity Eq. Exponent (mfa):  %f\n',mfa);
fprintf(FID_LOG,'(Fluvial Process)  Transport Capacity Eq. Exponent (nfa):  %f\n',nfa);
fprintf(FID_LOG,'(To Compare with Previous Research) Bedrock Incision Eq. Coefficient and Exponents\n');
KO = bankfullTime * kfbre * wRho * g * nB^mfb * kqb^((1 - mhw) * mfb) ...
    * annualRunoff^((1 - mhw) * mqb * mfb) ...
    * SECPERYEAR^((mhw - 1) * mqb * mfb) / khw^mfb;
mO = mqb * (1 - mhw) * mfb;
nO = nfb;
fprintf(FID_LOG,'(Fluvial Process)  Bedrock Incision Eq. Coefficient (K):   %f\n',KO);
fprintf(FID_LOG,'(Fluvial Process)  Bedrock Incision Eq. Coefficient (m):   %f\n',mO);
fprintf(FID_LOG,'(Fluvial Process)  Bedrock Incision Eq. Coefficient (n):   %f\n',nO);

% parameterValuesFile �� OUTPUT_SUBDIR �� ������
copyfile(INPUT_FILE_PARAM_PATH,OUTPUT_SUBDIR_PATH);

%--------------------------------------------------------------------------
% (GPSS 2D �� �Լ�) �����ð����� �Ʒ��� �ݺ���

for ithTimeStep = INIT_TIME_STEP_NO:TIME_STEPS_NO
    
    fprintf('%g\n', ithTimeStep);   % ���� Ƚ�� ���
    
    % 1. ������ǿ� ���� �ܰ� ����� ��ݾ� ���� ������ �β��� ������
    % * ����: �ܰ� ����� ���� AdjustBoundary �Լ������� ������. ����
    %   �Ʒ��� ���������ۿ뿡 ���� ���� �������� ������ ���� ���� �ݿ�����
    %   ����. �� ���� ���ԵǴ� ������ ��� ���ŵȴٰ� ������
    [bedrockElev ...            % �ܰ� ��������� �� ��ݾ� �� [m]
    ,sedimentThick] ...         % �ܰ� ��������� �� ������ �β� [m]
        = AdjustBoundary(Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
        ,bedrockElev,sedimentThick,OUTER_BOUNDARY ...
        ,BOUNDARY_OUTFLOW_COND,TOP_BOUNDARY_ELEV_COND ...
        ,topBndElev,ithTimeStep,meanUpliftRateAtUpliftAxis);
    
    % 2. �������� �߻�
    bedrockElev ...            % ������������ �ݿ��� ��ݾ� �� [m]
        = Uplift(Y_INI,Y_MAX,X_INI,X_MAX ...
        ,bedrockElev ...
        ,upliftRateTemporalDistribution(ithTimeStep) ...
        ,meanUpliftRateSpatialDistribution ...
        ,meanUpliftRateAtUpliftAxis);
    
    % * ���� �ۿ� ���� ��ݾ� �� �� ������ �β��� ����Ͽ� ��� ��¿� �̿���
    preBedrockElev = bedrockElev;
    preSedThick = sedimentThick;
    
    % 3. ��ݾ� ǳȭ �� �̷� ���� ������ �β� �� ��ݾ� �� ��ȭ���� �ݿ���
    
    % 1) (�ϵ� ��� ������ �β��� ���ϱ� ����) �� ���� �� ���� ���ǿ�����
    %    ��������, ���������� ���� �� ���� �׸��� �ϵ� �� �ϻ� ���������� ����
    % * ����: �ϵ� �������� ǳȭ�ۿ��� �Ͼ�� �ʴ´ٰ� ������. �Ͼ� �Ǵ� ���
    %   �������� ���ؼ� ǳȭ�ۿ��� �߻��Ͽ� ��ݾ��� ǳȭ��.
    
    % (1) ����� ���
    
    % A. �� ����
    elev = bedrockElev + sedimentThick;
    
    % B. (���� ���� �˰����� �̿���) ����� ���
    [facetFlowDirection ...     % ����
    ,facetFlowSlope ...         % ���
    ,e1LinearIndicies ...       % ���� ��(e1) ����
    ,e2LinearIndicies ...       % ���� ��(e2) ����
    ,outputFluxRatioToE1 ...    % ���� ��(e1)���� ������
    ,outputFluxRatioToE2] ...   % ���� ��(e2)���� ������
        = CalcInfinitiveFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,QUARTER_PI,HALF_PI,elev,dX ...
        ,sE0LinearIndicies,s3E1LinearIndicies,s3E2LinearIndicies);
    
    % C. (�ִ��Ϻΰ�� ���� �˰����� �̿���) ����� ���
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
    
    % D. ������ ���ǵ��� ���� ���� ������ ������
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
    
    % (2) ��������, ���������� ���� �� ������ ����
    
    % A. ���� ����[m^3/yr]

    % A) ������ �� ������ ����
    elevForSorting = elev;
    
    % B) flooded region�� ������
    % * ���� : �����ϴ� ���� �������� - inf�� �Է���
    elevForSorting(flood == FLOODED) = - inf;

    % C) ���� �� ������ �����ϰ� ���� Y,X ��ǥ���� ����
    vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
    sortedYXElevForUpstreamFlow = [vectorY,vectorX,vectorElev];
    sortedYXElevForUpstreamFlow = sortrows(sortedYXElevForUpstreamFlow,-3);

    % D) AccumulateUpstreamFlow �Լ��� ��� �� ��
    consideringCellsNoForUpstreamFlow = find(vectorElev > - inf);
    consideringCellsNoForUpstreamFlow ...
        = size(consideringCellsNoForUpstreamFlow,1);

    % E) �������� [m^3/yr]
    [annualDischarge1 ...   % �������� [m^3/yr]
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

    % B. ��������, ���������� ���ɰ� ����
    
    % A) �� ������� [m^3/s]
    meanDischarge = annualDischarge1 / SECPERYEAR;

    % B) �������� [m^3/s]
    bankfullDischarge = kqb * meanDischarge .^ mqb;

    % C) ���������� ���� [m]
    bankfullWidth = khw * bankfullDischarge .^ mhw;

    % D) ���������� ����[m]
    bankfullDepth = khd * bankfullDischarge .^ mhd; % ��õ �������� ��Ģ���κ��� ����
    % bankfullDepth = ( (bankfullDischarge ./ bankfullWidth) ... % Manning �帧 ���׽����� ���� ����
    %    * nA .* integratedSlope .^ -0.5 ) .^ 0.6;
    
    % C. �ϵ� �� �ϻ� ������ [m^3]
    % * ����: �ϵ� �� ��� �ϻ� ������. FluvialProcess �Լ����� �и�����
    %   ȯ��� ������� ȯ���� �����ϴ� ������ ��. �� ���� �� ���� �����Ͽ���
    %   ��õ�� ��������Ư���� ���� ������ ������ �����ϰ�, ������ ����
    %   �ϻ󿡼����� ��ݾϱ����� �ϻ� ���������� ������.
    % * ����: �ϵ� �� �ϻ� �������� ��������� ����ϱ� ������ ����
    %   �̸� ���� '��鿡�� �ϵ����� ������'�� �ľ��ϰ�, '��õ�ۿ뿡 ����
    %   ���ŵǴ� ����'�� �ľ��Ͽ� �ϻ� �������� ������ �ð��� ������ �м��ϱ�
    %   ����. ������ �ϵ� ��ȿ��� �ϵ����� ���� �̵� ��Ŀ����(���� �Ž������Ʈ?
    %   ���� �Ž������Ʈ? ��õ ���� ħ������ ���� �Ͼ����κ����� ����?)��
    %   �������� �Һи��ϱ� ������ ������ parameterization�� �ʿ��Ͽ� �� �̻�
    %   �������� ����. ������ ���⼭ chanBedSedBudget�� ���� ���� chanBedSed��
    %   ������ �ľ��� ���� �õ��� ��.
    
    % A) �� ������ �β��� �� ��õ ��������Ư�����κ��� ���� �ϵ� �� �ϻ� ������
    
    % (A) �� ���ǿ����� ��õ�� ������ �� ����
    upslopeArea = annualDischarge1 ./ annualRunoff; % ��� �������� [m^3/yr]/[m/yr]
    
    channel ...
        = DefineChannel(upslopeArea,integratedSlope,channelInitiation ...
        ,CELL_AREA,criticalUpslopeCellsNo,flood,FLOODED);
        
    % (B) �ϵ� �� �ϻ� ������ �β� [m/bankfullWidth]
    chanBedSedThick = zeros(mRows,nCols);
    chanBedSedThick(channel) ...
        = sedimentThick(channel) ...
        + bankfullWidth(channel) .* bankfullDepth(channel) ./ dX ...
        - bankfullDepth(channel);
    
    % * ����: �� ������ �ϻ� ������ �β��� ���� ���, ��κ��� ������ ����
    %   �ϵ��� ������ sedimentThick�� ���� ������ ������
    chanBedSedThick(chanBedSedThick < 0) = 0;
    
    % D. ��� �� �ϵ� ��� ������ �β�
    
    % A) ��� ������ �β� [m]
    sedThickOutsideChannel = sedimentThick;
    
    % B) �ϵ� ��� ������ �β� [m]
    sedThickOutsideChannel(channel) ...
        = chanBedSedThick(channel) + bankfullDepth(channel);
    
    % 2) ǳȭ�� [m/dT]
    % * ����: flooded region�� �������� ����. flooded region������ ǳȭ��
    %   ������ ���ٰ� ������
    weatheringProductPerDT ...
        = RockWeathering(kwa,kw0,kw1,kwm ...
        ,sedThickOutsideChannel,bankfullWidth,dX,dT);
    
    weatheringProductPerDT(flood == FLOODED) = 0;
    
    % 3) ǳȭ�ۿ����� ���� ������ �β� �� ��ݾ� �� ����
    sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + weatheringProductPerDT(Y_INI:Y_MAX,X_INI:X_MAX);
    bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        - weatheringProductPerDT(Y_INI:Y_MAX,X_INI:X_MAX);

    % 4. ����ۿ�� �̷� ���� ������ �β� ��ȭ
    
    % 1) ���� �������� ���� (ǳȭ�� ���� �� ��ȭ�� �����Ƿ� ����)
    % elev = bedrockElev + sedimentThick;

    % 2) (�� �ܺη�) ����ۿ� �߻� ������ ���� �� ������ ������
    elevForSorting = elev;
    
    % (1) ��õ�� ���� ������
    % * ����: ��õ�� ���� ���� �������� ����
    elevForSorting(flood == FLOODED | channel) = - inf;

    % (2) ���� �� ������ �����ϰ� ���� Y,X ��ǥ���� ����
    vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
    sortedYXElev = [vectorY,vectorX,vectorElev];
    sortedYXElev = sortrows(sortedYXElev,-3);

    % (3) ����ۿ��� �Ͼ�� ������ ���� ����
    consideringCellsNo = find(vectorElev > - inf);
    consideringCellsNo = size(consideringCellsNo,1);

    % 3) ����ۿ뿡 ���� ������ �β� ��ȭ���� �ϵ����� ��鹰�� ������
    dSedThickByHillslopePerDT ... % ����ۿ����� ���� ������ �β� ��ȭ�� [m/dT]
        = HillslopeProcess(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,dX,dT,CELL_AREA ...
        ,sortedYXElev,consideringCellsNo ...
        ,s3IthNbrLinearIndicies ...
        ,sedimentThick,kmd ...
        ,flood,floodedRegionCellsNo,floodedRegionIndex ...
        ,SDSNbrY,SDSNbrX,slopeAllNbr);
    
    % 4) ������ �β��� ������
    sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + dSedThickByHillslopePerDT(Y_INI:Y_MAX,X_INI:X_MAX);
    
    % 4. ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ� �� ��ȭ��
    % * ���� : ����� �Ϸ��� �⺹ ���� ������ �ذ��ϱ� ����, ��������
    %   ���ӱⰣ���� ���� ���� �����ð��� �����ϰ� �������� ���ӱⰣ�� ������
    %   ������ �ݺ���
    
    % 1) ���� �����ð� ���� ���� �ʱ�ȭ
    ithSubTimeStep = 1;             % ���� ���� ���� Ƚ��
    sumSubDT = 0;                   % ���� �����ð��� ���� �հ�
    dSedThickByFluvialPerDT ...     % ������ �β� ��ȭ��[m^3/m^2 dT]
        = zeros(mRows,nCols);
    dBedrockElevByFluvialPerDT ...  % ��ݾ� �� ��ȭ��[m^3/m^2 dT]
        = zeros(mRows,nCols);
    
    % 2) �������� ���ӱⰣ�� ������ ������ �ݺ���
    while (sumSubDT < bankfullTime)
        
        % (1) ���� �����ð� ������ ����� ��縦 ������

        % A. (����� ��縦 ���ϱ� ����) ���� ������
        % * ���� : EstimateSubDT �Լ����� �Է� �����ε� ����
        elev = bedrockElev + sedimentThick;
        
        % B. ���� ���� �˰����� �̿��� ����� ���
        [facetFlowDirection ...     % ����
        ,facetFlowSlope ...         % ���
        ,e1LinearIndicies ...       % ���� ��(e1) ����
        ,e2LinearIndicies ...       % ���� ��(e2) ����
        ,outputFluxRatioToE1 ...    % ���� ��(e1)���� �й���
        ,outputFluxRatioToE2] ...   % ���� ��(e2)���� �й���
            = CalcInfinitiveFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,QUARTER_PI,HALF_PI,elev,dX ...
            ,sE0LinearIndicies,s3E1LinearIndicies,s3E2LinearIndicies);

        % C. �ִ��Ϻΰ�� ���� �˰����� �̿��� ����� ���
        [steepestDescentSlope ...   % ���
        ,slopeAllNbr ...            % 8 �̿� ������ ���
        ,SDSFlowDirection ...       % ����
        ,SDSNbrY ...                % ���� ���� Y ��ǥ��
        ,SDSNbrX] ...               % ���� ���� X ��ǥ��
            = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND ...
            ,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX ...
            ,IS_LEFT_RIGHT_CONNECTED ...
            ,ithNbrYOffset,ithNbrXOffset ...
            ,sE0LinearIndicies,s3IthNbrLinearIndicies);

        % D. ������ ���ǵ��� ���� ���� ������ �ο���
        % * sink�� ������ �ο��ϰ�, flooded region�� ������ �缳����
        [flood ...                      % flooded region
        ,SDSNbrY ...                    % ������ ���� ���� Y ��ǥ��
        ,SDSNbrX ...                    % ������ ���� ���� X ��ǥ��
        ,SDSFlowDirection ...           % ������ ����
        ,steepestDescentSlope ...       % ������ ���
        ,integratedSlope ...            % ������ facet flow ���
        ,floodedRegionIndex ...         % flooded region ����
        ,floodedRegionCellsNo ...       % �� flooed region ���� �� ����
        ,floodedRegionLocalDepth ...    % flooded region ���� ���ⱸ ������ ����
        ,floodedRegionTotalDepth ...    % �� local depth
        ,floodedRegionStorageVolume] ...% flooded region �� ���差
            = ProcessSink(mRows,nCols,X_INI,X_MAX ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,CELL_AREA ...
            ,elev,ithNbrYOffset,ithNbrXOffset ...
            ,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
            ,slopeAllNbr,steepestDescentSlope ...
            ,facetFlowSlope,SDSNbrY,SDSNbrX,SDSFlowDirection);

        % (2) ���ŵ� ���⿡ ���� �������� [m^3/s]�� ���ϰ�, ��õ�� ��������
        %     Ư���� �̿��� ���������� ������ ������ ����
        % * ����: ���������� �� �������[m^3/s]���� ����Ŀ��� ����

        % A. �������� [m^3/dT]

        % A) (���������� ���ϱ� ����) ������ �� ������ ����
        
        % (A) flooded region�� ������
        % * ����: �����ϴ� ���� �������� - inf �� �Է�
        elevForSorting = elev;
        elevForSorting(flood == FLOODED) = - inf;
        
        % (B) ���� �� ������ �����ϰ� Y,X ��ǥ���� ����
        vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
        sortedYXElevForUpstreamFlow = [vectorY,vectorX,vectorElev];
        sortedYXElevForUpstreamFlow ...
            = sortrows(sortedYXElevForUpstreamFlow,-3);
        
        % B) AccumulateUpstreamFlow �Լ� ��� ������ ��
        consideringCellsNoForUpstreamFlow = find(vectorElev > - inf);
        consideringCellsNoForUpstreamFlow ...
            = size(consideringCellsNoForUpstreamFlow,1);

        % C) ��������
        [annualDischarge1 ...   % ���� ���� [m^3/dT]
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

        % B. ��������, ���������� ������ ����
        
        % A) �� �������[m^3/s]
        meanDischarge = annualDischarge1 / SECPERYEAR;

        % B) ��������[m^3/s]
        bankfullDischarge = kqb * meanDischarge .^ mqb;

        % C) ���������� ����[m]
        bankfullWidth = khw * bankfullDischarge .^ mhw;
        
        % D) ���������� ����[m]
        bankfullDepth = khd * bankfullDischarge .^ mhd; % ��õ �������� ��Ģ���κ��� ����
        % bankfullDepth = ( (bankfullDischarge ./ bankfullWidth) ... % Manning �帧 ���׽����� ���� ����
        %    * nA .* integratedSlope .^ -0.5 ) .^ 0.6;        
        
        % (3) ���� �����ð��� ������
        % * ����: �ӽ� ���� �����ð� ���� ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ�
        %   �� ��ȭ�� ���� ���� ������ ��簡 0�� �Ǵ� �ּ� �ð�(�⺹������
        %   �߻����� �ʴ� �ִ� �ð�)�� ���ϰ� �̸� ���� �����ð����� ������
        
        % A. �ӽ� ���� �����ð� ������ ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ�
        %    �� ��ȭ���� ����
        
        % A) ������ �� ������ ������
                
        % (A) ��õ�� �����ϰ�, ��õ�� �ƴ� ������ ������
        % * ����: flooded region�� ������. ���� �� ��ȭ���� FluvialProcess
        %   �Լ����� ���ϱ� ������
        % * ����: shalow overland flow�� ���� �����̵��� ����� ���, ��鿡��
        %   �� �Ǵ� ������� ���� ħ���� �߻���. ���� �̸� ����ϱ� ����
        %   hillslope�� ������
        elevForSorting = elev;        
        
        upslopeArea = annualDischarge1 ./ annualRunoff; % ��� �������� [m^3/yr]/[m/yr]

        channel ...
            = DefineChannel(upslopeArea,integratedSlope,channelInitiation ...
            ,CELL_AREA,criticalUpslopeCellsNo,flood,FLOODED);
        
        hillslope = ~ channel;
        
        % ��õ�� �ƴ� ������ ������ ���
        % elevForSorting(flood == FLOODED | ~ channel) = - inf;
        % ��鿡���� ��� ħ�ı��� ��� ���� ���
        elevForSorting(flood == FLOODED) = - inf;
        
        % (B) ���� �� ������ �����ϰ� ���� Y,X ��ǥ���� ����
        vectorElev = reshape(elevForSorting(Y_INI:Y_MAX,X_INI:X_MAX),[],1);
        sortedYXElevForFluvial = [vectorY,vectorX,vectorElev];
        sortedYXElevForFluvial = sortrows(sortedYXElevForFluvial,-3);

        % B) ��õ�ۿ��� �Ͼ�� ������ ���� ����
        consideringCellsNoForFluvial = find(vectorElev > - inf);
        consideringCellsNoForFluvial ...
            = size(consideringCellsNoForFluvial,1);
        
        % C) �ӽ� ���� �����ð��� ������
        trialTime ...
            = bankfullTime * basicManipulationRatio ^ nt;
                
        % D) �ϵ� �� �ϻ� ������ [m^3]
        
        % (A) �ϵ� �� �ϻ� ������ �β� [m/bankfullWidth]
        chanBedSedThick = zeros(mRows,nCols);
        chanBedSedThick(channel) ...
            = sedimentThick(channel) ...
            + bankfullWidth(channel) .* bankfullDepth(channel) ./ dX ...
            - bankfullDepth(channel);
        
        % * ����: �� ������ �ϻ� ������ �β��� ���� ���, ��κ��� ������ ����
        %   �ϵ��� ������ sedimentThick�� ���� ������ ������
        chanBedSedThick(chanBedSedThick < 0) = 0;
        
        % (B) �ϵ� �� �ϻ� ������ ���� [m^3]
        chanBedSed = chanBedSedThick * dX .* bankfullWidth;
        
        % (C) ���� �ϵ� �� �ϻ� ������ ���ǿ� ��
        % * Ȯ���� ����: 1) �����ϴ� ���� 2) �����ϴ� ��찡 ��� ������ ��
        %   �߻��ϴ��� Ȯ���غ� ��. ����δ� �� ���� �Ǵ� ���� ���� �Ʒ����� ������
        %   ������ �̿� ���� ���������� ��ȭ�� ���� ������ �����. Ư�� ��õ��
        %   ��������Ư���� ���ɺ��ٴ� ������ �������� ũ�Ƿ�, ���� ������ ����������
        %   ������ ������ �̷� ���� ���� �ϻ� ���������� ������ ������ �����.
        % dChanBedSedPerDT = chanBedSedPerDT + (chanBedSed - oldChanBedSed);

        % oldChanBedSed = chanBedSed;

        % (D) ���� ��õ�ۿ� ���� �ϵ� �� �ϻ� ������ ������ ��ȭ
        % * ����: 1) �����ϴ� ���: �ϵ��� Ȱ���� ħ������ ���� �ϵ� ���
        %   ���������κ����� ����(��õ�� ����ħ�� �Ǵ� �ϵ� ����� ����ۿ�)
        %   * (C)�� 1)�� ���� ȿ���� ������ ����
        %   2) �����ϴ� ���: ����κ����� �ϻ� ������ ���� �Ǵ� ����ۿ뿡 ����
        %   ��鹰�� �������� ���Ҵ� ���. ���ҵ� ���� �ϵ� ��ȿ� �����Ǿ��ٰ�
        %   ������. * (C)�� 2)�� ���� ȿ���� ������ ����
        chanBedSedBudgetPerDT = chanBedSedBudgetPerDT ...
            + (chanBedSed - remnantChanBedSed); 
        
        % E) �ӽ� ���� �����ð� ���� ������ �β� �� ��ݾ� �� ��ȭ��
        [dSedThickByFluvialForSubDT ...     % ������ �ΰ� ��ȭ��[m/trialTime]
        ,dBedrockElevByFluvialForSubDT ...  % ��ݾ� �� ��ȭ��[m/trialTime]
        ,dChanBedSedForSubDT] ...            % �ϵ� �� �ϻ� ������ �β� [m^3]   
            = FluvialProcess(mRows,nCols ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,FLUVIALPROCESS_COND,timeWeight ...
            ,sortedYXElevForFluvial,consideringCellsNoForFluvial ...
            ,channel,chanBedSed,hillslope,sedimentThick ...
            ,OUTER_BOUNDARY ...
            ,bankfullDischarge,bankfullWidth,flood ...
            ,floodedRegionIndex,floodedRegionCellsNo,floodedRegionLocalDepth ...
            ,floodedRegionTotalDepth,floodedRegionStorageVolume ...
            ,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1 ...
            ,outputFluxRatioToE2,SDSNbrY,SDSNbrX,integratedSlope ...
            ,kfa,mfa,nfa,kfbre,fSRho,g,nB,mfb,nfb,trialTime,dX);
        
        % B. ���� �����ð��� ������
        [subDT ...              % ���� �����ð� [s]
        ,sumSubDT ...           % ���� ���� �����ð� [s]
        ,nt] ...                % ���� �����ð� ������ ���� ����
            = EstimateSubDT(mRows,nCols,elev ...
            ,dSedThickByFluvialForSubDT,dBedrockElevByFluvialForSubDT ...
            ,trialTime,sumSubDT,minSubDT ...
            ,basicManipulationRatio,nt,bankfullTime ...
            ,consideringCellsNoForFluvial,sortedYXElevForFluvial ...
            ,SDSNbrY,SDSNbrX,floodedRegionCellsNo ...
            ,e1LinearIndicies,outputFluxRatioToE1 ...
            ,e2LinearIndicies,outputFluxRatioToE2);
        
        % (4) ���� �����ð� ���� ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ� ��ȭ��
        
        % A. ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ� ��ȭ��
        % * ������ �� ������ �ٽ� �������� �ʰ�, EstimateMinTakenTime �Լ�
        %   �ÿ� �����ߴ� ���� �̿���
        [dSedThickByFluvialPerSubDT ...    % ������ �β� ��ȭ�� [m^3/m^2 subDT]
        ,dBedrockElevByFluvialPerSubDT ...      % ��ݾ� �� ��ȭ�� [m^3/m^2 subDT]
        ,dChanBedSedPerSubDT] ...               % �ϵ� �� �ϻ� ������ �β� [m^3]
            = FluvialProcess(mRows,nCols ...
            ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,CELL_AREA ...
            ,FLUVIALPROCESS_COND,timeWeight ...
            ,sortedYXElevForFluvial,consideringCellsNoForFluvial ...
            ,channel,chanBedSed,hillslope,sedimentThick ...
            ,OUTER_BOUNDARY ...
            ,bankfullDischarge,bankfullWidth,flood ...
            ,floodedRegionIndex,floodedRegionCellsNo ...
            ,floodedRegionLocalDepth,floodedRegionTotalDepth ...
            ,floodedRegionStorageVolume ...
            ,e1LinearIndicies,e2LinearIndicies,outputFluxRatioToE1 ...
            ,outputFluxRatioToE2,SDSNbrY,SDSNbrX,integratedSlope ...
            ,kfa,mfa,nfa,kfbre,fSRho,g,nB,mfb,nfb,subDT,dX);
        
        % B. ���� �����ð��� ������ �β� �� ��ݾ� �� ��ȭ���� �����ϰ�
        %    �ϵ� �� �ϻ� �������� ������
        dSedThickByFluvialPerDT ...
            = dSedThickByFluvialPerDT + dSedThickByFluvialPerSubDT;
        dBedrockElevByFluvialPerDT ...
            = dBedrockElevByFluvialPerDT + dBedrockElevByFluvialPerSubDT;
        remnantChanBedSed = chanBedSed + dChanBedSedPerSubDT;
        
        % C. ������ �β� �� ��ݾ� �� ��ȭ���� �� ������ �ݿ���
        sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
            = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
            + dSedThickByFluvialPerSubDT(Y_INI:Y_MAX,X_INI:X_MAX);
        bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
            = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
            + dBedrockElevByFluvialPerSubDT(Y_INI:Y_MAX,X_INI:X_MAX);
        
        % (5) ���� ���� Ƚ���� �ϳ� ������
        ithSubTimeStep = ithSubTimeStep + 1;
        
    end % while (sumSubDT < bankfullTime)
    
    % 5. ���� �Ž������Ʈ�� ���� ������ �β� �� ��ݾ� �� ��ȭ��
    % * ����: �Ҿ����� ����� �ľ��ϰ�, �̵鿡 ���� ���� �Ž������Ʈ�� �߻�����
    %   ��鹰���� �Ϻη� �����̵� ��Ŵ
    
    % 1) ���� �Ž������Ʈ�� ���� ������ �β� �� ��ݾ� �� ��ȭ��
    [dBedrockElevByRapidMass ...        % ��ݾ� �� ��ȭ�� [m/dT]
    ,dSedThickByRapidMass ...          % ������ �β� ��ȭ�� [m/dT]
    ,dTAfterLastShallowLandslide ...    % ������ õ��Ȱ�� ���� ��� �ð�
    ,dTAfterLastBedrockLandslide] ...   % ������ ��ݾ�Ȱ�� ���� ��� �ð�
        = RapidMassMovement(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX ...
        ,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,dT,ROOT2,QUARTER_PI ...
        ,CELL_AREA,DISTANCE_RATIO_TO_NBR,soilCriticalSlopeForFailure ...
        ,rockCriticalSlopeForFailure,bedrockElev,sedimentThick ...
        ,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide ...
        ,dX,OUTER_BOUNDARY,IS_LEFT_RIGHT_CONNECTED ...
        ,ithNbrYOffset,ithNbrXOffset ...
        ,sE0LinearIndicies,s3IthNbrLinearIndicies);

    % 2) ��ݾ� ���� ������ �β��� ������
    bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        = bedrockElev(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + dBedrockElevByRapidMass(Y_INI:Y_MAX,X_INI:X_MAX);
    sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX)...
        = sedimentThick(Y_INI:Y_MAX,X_INI:X_MAX) ...
        + dSedThickByRapidMass(Y_INI:Y_MAX,X_INI:X_MAX);
    % for debug
    if sum(sum(dSedThickByRapidMass(Y_INI:Y_MAX,X_INI:X_MAX))) > 0
       
        fprintf('%g\n', ithTimeStep);   % ���� Ƚ�� ���
        
    end
    
    % ���� ���� Ƚ�� �������� ���� ����� ���Ͽ� ����Ѵ�.
    if mod(ithTimeStep,WRITE_INTERVAL) == 0
       
        % ǳȭ�� ����
        fprintf(FID_WEATHER,'%14.10f\n',weatheringProductPerDT);        
        % (���� �ۿ����� ���� ��ȭ ��) ������ �β�
        fprintf(FID_SEDTHICK,'%14.10f\n',preSedThick);        
        % (���� �ۿ����� ���� ��ȭ ��) ��ݾ� ��
        fprintf(FID_BEDROCKELEV,'%14.10f\n',preBedrockElev);        
        % ����ۿ뿡 ���� ������ �β� ��ȭ��
        fprintf(FID_dSEDTHICK_BYHILLSLOPE,'%14.10f\n',dSedThickByHillslopePerDT);
        % �ϵ� �� �ϻ� ������ ����
        fprintf(FID_CHANBEDSEDBUDGET,'%14.10f\n',chanBedSedBudgetPerDT);
        % ��õ�ۿ뿡 ���� ������ �β� ��ȭ��
        fprintf(FID_dSEDTHICK_BYFLUVIAL,'%14.10f\n',dSedThickByFluvialPerDT);        
        % ��õ�ۿ뿡 ���� ��ݾ� �� ��ȭ��
        fprintf(FID_dBEDROCKELEV_BYFLUVIAL,'%14.10f\n',dBedrockElevByFluvialPerDT);
        % ���� �Ž������Ʈ�� ���� ������ �β� ��ȭ��
        fprintf(FID_dSEDTHICK_BYRAPIDMASS,'%14.10f\n',dSedThickByRapidMass);        
        % ���� �Ž������Ʈ�� ���� ��ݾ� �� ��ȭ��
        fprintf(FID_dBEDROCKELEV_BYRAPIDMASS,'%14.10f\n',dBedrockElevByRapidMass);
        
    end % if mod(ithTimeStep,WRITE_INTERVAL) == 0
    
end % for ithTimeStep = 1:TIME_STEPS_NO

% GPSS 2D ���� �ð��� ��ü �ҿ� �ð��� �α� ���Ͽ� ����Ѵ�.
finishedTime = clock;
elapsedTime = datenum(finishedTime) - datenum(startedTime);
elapsedTime = datevec(elapsedTime);

fprintf(FID_LOG,'GPSS 2D finished time : %i[year] %i[month] %i[day] %i[hr] %i[min] %f[sec]\n' ...
    ,finishedTime);

fprintf(FID_LOG,'GPSS 2D running time : %i[year] %i[month] %i[day] %i[hr] %i[min] %f[sec]\n' ...
    ,elapsedTime);

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

end % main function end