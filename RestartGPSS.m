% =========================================================================
%> @section INTRO RestartGPSS
%>
%> - GPSS ������ ���ڱ� ������ ��쿡�� �����Ͽ� ���ǽ����� ������ �� �ֵ���
%>   �����ִ� �Լ�
%>  - ���ݱ��� ��ϵ� ���ǰ�� ���Ϸ� ���� ���� ����� ����Ƚ���� �ľ��ϰ�
%>    ���� ���࿡ �ʱ� ���� �������� ���� ��ݾ� ���� ������ �β���
%>    �����Ͽ� ���Ͽ� �����
%>  - ���� ���࿡ ���� ��ݾ� ���� ������ �β� ������ input ���丮��
%>    �ű��, paraterValues.txt������ �Ʒ��� �׸��� �����ϰ� GPSSMain()��
%>    ������ϸ� ��
%>    - INIT_BEDROCK_ELEV_FILE : (�ʱ������� �ҷ��� ���) �ʱ������� ������ ����. ���ٸ� No ��� ǥ����
%>    - newInitBedrockElev.txt
%>    - ...
%>    - INIT_SED_THICK_FILE : �ʱ� ������ ������ �β��� �ҷ��� ��� �̸� ������ ����. ���ٸ� No ��� ǥ����
%>    - newInitSedThick.txt
%>    - ...
%>    - INIT_TIME_STEP_NO : ���� ���� ������� �̾ �� ����� �ʱ� ���� Ƚ��. �̾ ���� �ʴ´ٸ� 1
%>    - newInitTimeStepNo
%>
%> - ���� �ۼ��� : 2011-10-08
%>
%> - Histroy
%>
%> - �߰�����
%>  - �� �ڵ��� �������� Johnson (2002)�� ������ ǥ�� ��õ�� ������, ������ ����.
%> "1. > 1) > (1) > A. > A) > (A) > a. > a) > (a)"
%>
%> @callgraph
%> @callergraph
%> @version 0.1
%>
%> 
%> @retval newInitTimeStepNo            : ���� ����� �ʱ� ���� Ƚ��
%>
%> @param OUTPUT_SUBDIR                 : GPSS ������ ������ ���ǽ��� ����� ����� ���͸���
%> @param Y                             : �ܰ� ��踦 ����ȯ Y�� ũ��
%> @param X                             : �ܰ� ��踦 ������ X�� ũ��
%> @param dT                            : �������� �����Ⱓ
%> @param WRITE_INTERVAL                : ���ǰ���� ����ϴ� ��
%>
% =========================================================================
function newInitTimeStepNo = RestartGPSS(OUTPUT_SUBDIR,Y,X,WRITE_INTERVAL)
%
% RestartGPSS
%

% ��� ����
mRows = Y + 2;
nCols = X + 2;

% 1. ���ǰ�� ��� ���ϵ��� ��

% ���ǰ�� ������ �����ϴ� ���͸� ����
DATA_DIR = 'data';      % ����� ������ �����ϴ� �ֻ��� ���͸�
OUTPUT_DIR = 'output';  % ��� ������ ������ ���͸�
OUTPUT_DIR_PATH = fullfile(DATA_DIR,OUTPUT_DIR);
OUTPUT_SUBDIR_PATH = fullfile(OUTPUT_DIR_PATH,OUTPUT_SUBDIR);

% ���ǰ�� ���� ����
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

% ���ǰ�� ������ ��� ����
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

% 2. ���� ���� Ƚ���� �ľ���

% 1) sedThick.txt�� ������ �� ��ȣ�� �ľ���
nLines = 0;
while (fgets(FID_SEDTHICK) ~= -1) % �ؽ�Ʈ ���ڿ�(string)�� 'eof' �����ڸ� ������ ���� ���
    nLines = nLines + 1;
end
fseek(FID_SEDTHICK, 0, 'bof'); % ������ ���� ������ ó������ ���ư�

% 2) ���� ������ �ʱ� ���� Ƚ��
lastWritingCount = nLines / (mRows * nCols) - 1; % ���������� ��ϵ� Ƚ��

% * ����: dt�� ������ ���� 
newInitTimeStepNo = lastWritingCount * WRITE_INTERVAL + 1;

% 3. ���� ������ �ʱ� ��ݾ� ���� ������ �β��� ����


% 1) �ʱ� ������ �β��� ��ݾ� �� ����

% * ����: �̴� �ʱ� ���� �� �ʱ� ������ �β��� ��� ���Ͽ� ����ϱ� ������
initSedThick = fscanf(FID_SEDTHICK,'%f',[mRows,nCols]);
initBedrockElev = fscanf(FID_BEDROCKELEV,'%f',[mRows,nCols]);

% 2) ���������� ��ϵ� Ƚ�� ������ �о����
for ithWritingStep = 1:(lastWritingCount - 1)
    
    % * ����: �ҷ����� ������ �β� �� ��ݾ� ���� GPSSMain()���� AdjustBoundary,
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
    
end

% 3) ���������� ��ϵ� Ƚ���� ������ ������
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

% chanBedSedBudget ...                % �ϵ� �� �ϻ� ������ ���� ���� [m^3/dT]
%     = fscanf(FID_CHANBEDSEDBUDGET,'%f',[mRows,nCols]);

% 4) ������ Ƚ������ ���� �ۿ����� ���� ��ȭ���� ��ݾ� ���� ������ �β��� �ݿ���
bedrockElev = bedrockElev - weatheringProduct ...
            + dBedrockElevByFluvialPerDT + dBedrockElevByRapidMassPerDT;

sedimentThick = sedimentThick + weatheringProduct ...
                + dSedThickByHillslopePerDT + dSedThickByFluvialPerDT ...
                + dSedThickByRapidMassPerDT;
            
% 3. ���Ϸ� ����ϱ�
OUTPUT_FILE_NEWINIT_SEDTHICK ...                % ���� ������ �ʱ� ������ �β� [m]
    = 'newInitSedThick.txt';
OUTPUT_FILE_NEWINIT_BEDROCKELEV ...             % ���� ������ �ʱ� ��ݾ� �� [m]
    = 'newInitBedrockElev.txt';

OUTPUT_FILE_NEWINIT_SEDTHICK_PATH ...`
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_NEWINIT_SEDTHICK);
OUTPUT_FILE_NEWINIT_BEDROCKELEV_PATH ...
    = fullfile(OUTPUT_SUBDIR_PATH,OUTPUT_FILE_NEWINIT_BEDROCKELEV);

FID_NEWINIT_SEDTHICK = fopen(OUTPUT_FILE_NEWINIT_SEDTHICK_PATH,'w');
FID_NEWINIT_BEDROCKELEV = fopen(OUTPUT_FILE_NEWINIT_BEDROCKELEV_PATH,'w');

% ���� ������ �ʱ� ������ �β�
fprintf(FID_NEWINIT_SEDTHICK,'%i\n',mRows);
fprintf(FID_NEWINIT_SEDTHICK,'%i\n',nCols);
fprintf(FID_NEWINIT_SEDTHICK,'%14.10f\n',sedimentThick);        
% ���� ������ �ʱ� ��ݾ� ��
% * ����: �ʱ� ��ݾ� ���� ���� ���Ͽ��� ���� ù�ٰ� ��°�ٿ� ��� �� ������
%   ��ϵǾ�� ��.
fprintf(FID_NEWINIT_BEDROCKELEV,'%i\n',mRows);
fprintf(FID_NEWINIT_BEDROCKELEV,'%i\n',nCols);
fprintf(FID_NEWINIT_BEDROCKELEV,'%14.10f\n',bedrockElev);

% 4. ���� �ݱ�
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

fclose(FID_NEWINIT_SEDTHICK);
fclose(FID_NEWINIT_BEDROCKELEV);


% 5. Ȯ���ϱ�
% elev = bedrockElev + sedimentThick;
% Y_INI = 2;
% Y_MAX = Y + 1;
% X_INI = 2;
% X_MAX = X + 1;
% imshow(elev(Y_INI:Y_MAX,X_INI:X_MAX),[],'InitialMagnification','fit')
% colormap jet
% colorbar

