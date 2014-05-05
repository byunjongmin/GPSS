% =========================================================================
%> @section INTRO LoadParameterValues
%>
%> - ���Ͽ��� �ʱ� �������� �а� �̸� ����ϴ� �Լ�
%>  - ���� ��õ�� ���� ������ ��ݷ� ������ ����� ���ϰ� �̸� ��ȯ��
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%> @see ReadParameterValue()
%>
%> @retval OUTPUT_SUBDIR                    : ��� ������ ������ ���� ���͸�
%> @retval Y                                : (�ʱ� ������ ���� ���) �ܰ� ��踦 ������ Y�� ũ��
%> @retval X                                : (�ʱ� ������ ���� ���) �ܰ� ��踦 ������ X�� ũ��
%> @retval dX                               : �� ũ�� [m]
%> @retval PLANE_ANGLE                      : (�ʱ� ������ ���� ���) ��ź���� ��� [m/m]
%> @retval INIT_BEDROCK_ELEV_FILE           : (�ʱ� ������ �ҷ��� ���) �ʱ� ������ ������ ����
%> @retval initSedThick                     : �ʱ� ������ �β� [m]
%> @retval INIT_SED_THICK_FILE              : �ʱ� ������ ������ �β��� �ҷ��� ��� �̸� ������ ����
%> @retval TIME_STEPS_NO                    : �� ���� Ƚ��
%> @retval INIT_TIME_STEP_NO                : ���� ���� ������� �̾ �� ����� �ʱ� ���� Ƚ��
%> @retval dT                               : TIME_STEPS_NO�� ���̱� ���� �������� �����Ⱓ [year]
%> @retval WRITE_INTERVAL                   : ���� ����� ����ϴ� �� ����
%> @retval BOUNDARY_OUTFLOW_COND            : �� �������κ��� ������ �߻��ϴ� ���ⱸ �Ǵ� ��踦 ����
%> @retval TOP_BOUNDARY_ELEV_COND           : �� �ܰ� ��� �� ����
%> @retval IS_LEFT_RIGHT_CONNECTED          : �¿� �ܰ� ��� ������ ����
%> @retval TOTAL_ACCUMULATED_UPLIFT         : ���� �Ⱓ ���� �� ���� ���ⷮ [m]
%> @retval IS_TILTED_UPWARPING              : �浿�� ��� �������� ��� ����
%> @retval UPLIFT_AXIS_DISTANCE_FROM_COAST  : �ؾȼ����κ��� ����������� �Ÿ� [m]
%> @retval RAMP_ANGLE_TO_TOP                : (���� ���� ���ⷮ�� ����) �����࿡�� �� ������ �� [radian]
%> @retval Y_TOP_BND_FINAL_ELEV             : �� ����� ���� �� [m]
%> @retval UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND : �������� �ð��� ���� ����
%> @retval acceleratedUpliftPhaseNo         : (������ ���� ���� ����) ���ǱⰣ ���� ���� �������� �߻��ϴ� ��
%> @retval dUpliftRate                      : (������ ���� ���� ����) ��� ���� �������� �������� �ִ� �ּ� �������� ���� ����
%> @retval upliftRate0                      : (������ ����-���� ���� ����) ������ ��������� �ʱ� ������ [m/yearr]
%> @retval waveArrivalTime                  : (�浿�� ��� �������� ����) ���� �ܰ� ��� ���� ���������� �ϰ��ϴ� ���� (���� �Ⱓ���� ����)
%> @retval initUpliftRate                   : (�浿�� ��� �������� ����) ������ �ϰ� ���� ħ�� ���ظ� �ϰ��� [m/year]
%> @retval kw0                              : ���� ǳȭ�Լ����� ����Ǵ� ���� ��ݾ��� ǳȭ�� [m/year]
%> @retval kwa                              : ���� ǳȭ�Լ��� ������
%> @retval kw1                              : ���� ���� ǳȭ�Լ����� ����Ǵ� ���� ��ݾ��� ǳȭ�� [m/year]
%> @retval kwm                              : ǳȭ�� �β� ���� [m]
%> @retval kmd                              : ����ۿ��� Ȯ�� ���
%> @retval FAILURE_COND                     : Hillslope failure option
%> @retval soilCriticalSlopeForFailure      : õ��Ȱ���� ���� ��鰢 [radian]
%> @retval rockCriticalSlopeForFailure      : ��ݾ�Ȱ���� ���� ��鰢 [radian]
%> @retval FLOW_ROUTING                     : Flow routing algorithm option
%> @retval annualPrecipitation              : �� ���췮 [m/year]
%> @retval annualEvapotranspiration         : �� ���߻귮 [m/year]
%> @retval kqb                              : ��������� ������������ ����Ŀ��� ���
%> @retval mqb                              : ��������� ������������ ����Ŀ��� ����
%> @retval bankfullTime                     : �������� ���� �Ⱓ [s]
%> @retval timeWeight                       : �������� ���ӱⰣ�� ���̱� ���� ħ���� ����ġ
%> @retval minSubDT                         : �ּ����� ���δ��� �ð� [s]
%> @retval khw                              : ���������� �������� ����Ŀ��� ���
%> @retval mhw                              : ���������� �������� ����Ŀ��� ����
%> @retval khd                              : ���������� ���ɰ��� ����Ŀ��� ���
%> @retval mhd                              : ���������� ���ɰ��� ����Ŀ��� ����
%> @retval FLUVIALPROCESS_COND              : flooded region�� �� ������ �β� ��ȭ���� �����ϴ� ���
%> @retval channelInitiation                : ��õ ���� ���� �Ӱ谪
%> @retval criticalUpslopeCellsNo           : ��õ ���� �Ӱ� ������� �� ����
%> @retval mfa                              : ��õ�� ���� ������ ����� ���Ŀ��� ������ ����
%> @retval nfa                              : ��õ�� ���� ������ ����� ���Ŀ��� ����� ����
%> @retval fSRho                            : ��ݵǴ� �������� ��� �е� [kg/m^3]
%> @retval fSD50                            : ��ݵǴ� �������� �߰� �԰� [m]
%> @retval eta                              : ��ݵǴ� �������� ��� ������
%> @retval nA                               : ���� ��õ �ϵ������� Manning ���� ���
%> @retval mfb                              : ��ݾ� �ϻ� ħ���� ���Ŀ��� ������ ����
%> @retval nfb                              : ��ݾ� �ϻ� ħ���� ���Ŀ��� ����� ����
%> @retval kfbre                            : ��ݾ� �ϻ� ���൵
%> @retval nB                               : ��ݾ� �ϻ� �ϵ������� Manning ���� ���
%>
%> @param INPUT_FILE_PARAM_PATH             : �ʱ� �Էº����� ��ϵ� ���� �̸�
% =========================================================================
function [OUTPUT_SUBDIR,Y,X,dX,PLANE_ANGLE,INIT_BEDROCK_ELEV_FILE ...
    ,initSedThick,INIT_SED_THICK_FILE,TIME_STEPS_NO,INIT_TIME_STEP_NO ...
    ,dT,WRITE_INTERVAL,BOUNDARY_OUTFLOW_COND,TOP_BOUNDARY_ELEV_COND ...
    ,IS_LEFT_RIGHT_CONNECTED,TOTAL_ACCUMULATED_UPLIFT ...
    ,IS_TILTED_UPWARPING,UPLIFT_AXIS_DISTANCE_FROM_COAST ...
    ,RAMP_ANGLE_TO_TOP,Y_TOP_BND_FINAL_ELEV ...
    ,UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND,acceleratedUpliftPhaseNo ...
    ,dUpliftRate,upliftRate0,waveArrivalTime,initUpliftRate,kw0,kwa,kw1 ...
    ,kwm,kmd,FAILURE_OPT,soilCriticalSlopeForFailure,rockCriticalSlopeForFailure ...
    ,FLOW_ROUTING,annualPrecipitation,annualEvapotranspiration,kqb,mqb ...
    ,bankfullTime,timeWeight,minSubDT,khw,mhw,khd,mhd ...
    ,FLUVIALPROCESS_COND,channelInitiation,criticalUpslopeCellsNo,mfa ...
    ,nfa,fSRho,fSD50,eta,nA,mfb,nfb,kfbre,nB] ...
    = LoadParameterValues(INPUT_FILE_PARAM_PATH)
%
%

% ��� ����
NUMERIC = 1;
STRING = 2;

% ���� ����
fid = fopen(INPUT_FILE_PARAM_PATH,'r');
if fid == -1
    error('�ʱ� �������� ����� ������ ���� ���Ѵ�.\n');
end

% parameterValue file�� ���� ���� �κ��� �ǳ� ��
% tmpStrLine = fgetl(fid);
% tmpStrLine = fgetl(fid);
 
% �ʱ� ������ �Է�
%--------------------------------------------------------------------------
% ���͸� �� ���ϸ�

OUTPUT_SUBDIR ... % ��� ������ ������ ���� ���͸�
    = ReadParameterValue(fid,'OUTPUT_SUBDIR',STRING); 

%--------------------------------------------------------------------------
% �� ����

Y ... % (�ʱ� ������ ���� ���) �ܰ� ��踦 ������ Y �� ũ��
    = ReadParameterValue(fid,'Y',NUMERIC); 
X ... % (�ʱ� ������ ���� ���) �ܰ� ��踦 ������ X �� ũ��
    = ReadParameterValue(fid,'X',NUMERIC); 
dX ... % �� ũ�� [m]
    = ReadParameterValue(fid,'dX',NUMERIC);
PLANE_ANGLE ... % (�ʱ� ������ ���� ���) ��ź���� ��� [radian]
    = ReadParameterValue(fid,'PLANE_ANGLE',NUMERIC);
INIT_BEDROCK_ELEV_FILE ... % (�ʱ� ������ �ҷ��� ���) �ʱ� ������ ������ ����
    = ReadParameterValue(fid,'INIT_BEDROCK_ELEV_FILE',STRING);
initSedThick ... % �ʱ� ������ ������ �ΰ� [m]
    = ReadParameterValue(fid,'initSedThick',NUMERIC);
INIT_SED_THICK_FILE ...    % �ʱ� ������ ������ �β��� �ҷ��� ��� �̸� ������ ����
    = ReadParameterValue(fid,'INIT_SED_THICK_FILE',STRING);

%--------------------------------------------------------------------------
% ���� �� ��� Ƚ��

TIME_STEPS_NO ... % �� ���� Ƚ��
    = ReadParameterValue(fid,'TIME_STEPS_NO',NUMERIC);
INIT_TIME_STEP_NO ... % ���� ���� ������� �̾ �� ����� �ʱ� ���� Ƚ��
    = ReadParameterValue(fid,'INIT_TIME_STEP_NO',NUMERIC);
dT ... % TIME_STEPS_NO�� ���̱� ���� �������� �����Ⱓ [yr]
    = ReadParameterValue(fid,'dT',NUMERIC);
WRITE_INTERVAL ... % ���� ����� ����ϴ� �� ����
    = ReadParameterValue(fid,'WRITE_INTERVAL',NUMERIC);

%--------------------------------------------------------------------------
% �������

BOUNDARY_OUTFLOW_COND ... % �� �������κ��� ������ �߻��ϴ� ���ⱸ �Ǵ� �������
    = ReadParameterValue(fid,'BOUNDARY_OUTFLOW_COND',NUMERIC);
TOP_BOUNDARY_ELEV_COND ... % ���ⱸ �Ǵ� �ܰ� ��� �� ����
    = ReadParameterValue(fid,'TOP_BOUNDARY_ELEV_COND',NUMERIC);
IS_LEFT_RIGHT_CONNECTED ... % �¿� �ܰ� ��� ���� ����
    = ReadParameterValue(fid,'IS_LEFT_RIGHT_CONNECTED',NUMERIC);

%--------------------------------------------------------------------------
% �������� ������ �ð��� ����

TOTAL_ACCUMULATED_UPLIFT ... % ���� �Ⱓ ���� �� �������ⷮ [m]
    = ReadParameterValue(fid,'TOTAL_ACCUMULATED_UPLIFT',NUMERIC);
IS_TILTED_UPWARPING ... % �浿�� ��� �������� ����
    = ReadParameterValue(fid,'IS_TILTED_UPWARPING',NUMERIC);
UPLIFT_AXIS_DISTANCE_FROM_COAST ... % �ؾȼ����κ��� ����������� �Ÿ� [m]
    = ReadParameterValue(fid,'UPLIFT_AXIS_DISTANCE_FROM_COAST',NUMERIC);
RAMP_ANGLE_TO_TOP ... % (���� �������ⷮ�� ����) �����࿡�� �� ������ ��
    = ReadParameterValue(fid,'RAMP_ANGLE_TO_TOP',NUMERIC);
Y_TOP_BND_FINAL_ELEV ... % (�浿�� ��� �������� ���ǽ�) �� ����� ���� ��
    = ReadParameterValue(fid,'Y_TOP_BND_FINAL_ELEV',NUMERIC);
UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND ... % �������� �ð��� ���� ����
    = ReadParameterValue(fid,'UPLIFT_RATE_TEMPORAL_DISTRIBUTION_COND',NUMERIC);
acceleratedUpliftPhaseNo ... % (������ ���� ���� ����) ���ǱⰣ ���� ���� �������� �߻��ϴ� ��
	=  ReadParameterValue(fid,'acceleratedUpliftPhaseNo',NUMERIC);
dUpliftRate ... % (������ ���� ���� ����) ��� ���� �������� �������� �ִ� �ּ� �������� ���� ���� 
	=  ReadParameterValue(fid,'dUpliftRate',NUMERIC); % * ����: 0 < dUFraction <= 1
upliftRate0 ... % (������ ����-���� ���� ����) ������ ��������� �ʱ� ������ [m/yr]
	=  ReadParameterValue(fid,'upliftRate0',NUMERIC); % * ����: Min et al. (2008)
waveArrivalTime ... % (�浿�� ��� �������� ����) ���� �ܰ� ��� ���� ���������� �ϰ��ϴ� ���� (���� �Ⱓ���� ����)
	=  ReadParameterValue(fid,'waveArrivalTime',NUMERIC);
initUpliftRate ... % (�浿�� ��� �������� ����) ������ �ϰ� ���� ħ�� ���ظ� �ϰ��� [m/yr]
	=  ReadParameterValue(fid,'initUpliftRate',NUMERIC);

%--------------------------------------------------------------------------
% ��ݾ� ǳȭ �Լ�

% * ����: Anderson(2002)�� ��ݾ� ǳȭ �Լ��� �̿�.
kw0 ... % ���� ǳȭ �Լ����� ����Ǵ� ���� ��ݾ��� ǳȭ�� [m/yr]
    = ReadParameterValue(fid,'kw0',NUMERIC);
kwa ... % ���� ǳȭ �Լ��� ������
    = ReadParameterValue(fid,'kwa',NUMERIC);
kw1 ... % ���� ���� ǳȭ �Լ����� ����Ǵ� ���� ��ݾ��� ǳȭ�� [m/yr]
    = ReadParameterValue(fid,'kw1',NUMERIC);
kwm ... % ǳȭ�� �β� ���� [m]
    = ReadParameterValue(fid,'kwm',NUMERIC);

%--------------------------------------------------------------------------
% ����ۿ�

kmd ... % ����ۿ��� Ȯ�� ��� [m2/m yr]
    = ReadParameterValue(fid,'kmd',NUMERIC);
FAILURE_OPT ... % Hillslope failure option
    = ReadParameterValue(fid,'FAILURE_OPT',NUMERIC);
% * ����: �ϼ��ر� ������鰢���� �۰� ������
soilCriticalSlopeForFailure ... % �⼳���� ���� ��鰢
    = ReadParameterValue(fid,'soilCriticalSlopeForFailure',NUMERIC);
% * ����: ����õ �� ��õõ �ֻ�������� 0.5. * ����: �ػ󵵿� ���� �޶���
rockCriticalSlopeForFailure ... % �ϼ��ر��� ���� ��鰢
    = ReadParameterValue(fid,'rockCriticalSlopeForFailure',NUMERIC);

%--------------------------------------------------------------------------
% ����

FLOW_ROUTING ... % FLOW_ROUTING [m]
    = ReadParameterValue(fid,'FLOW_ROUTING',NUMERIC);
annualPrecipitation ... % ���� ���췮 [m/yr]
    = ReadParameterValue(fid,'annualPrecipitation',NUMERIC);
annualEvapotranspiration ... % ���� ���߻귮 [m/yr]
    = ReadParameterValue(fid,'annualEvapotranspiration', NUMERIC);

%--------------------------------------------------------------------------
% ��������

kqb ... % ��������� ������������ ����Ŀ��� ���
    = ReadParameterValue(fid,'kqb',NUMERIC); 
mqb ... % ��������� ������������ ����Ŀ��� ����
    = ReadParameterValue(fid,'mqb',NUMERIC);
bankfullTime ... % �������� ���ӱⰣ[s]
    = ReadParameterValue(fid,'bankfullTime',NUMERIC);
timeWeight ... % �������� ���ӱⰣ�� ���̱� ���� ����� �� ħ���� ����ġ
    = ReadParameterValue(fid,'timeWeight',NUMERIC);
minSubDT ... % �ּ����� ���δ��� �ð�[s]
    = ReadParameterValue(fid,'minSubDT',NUMERIC);

%--------------------------------------------------------------------------
% ��õ�� ���� ����

khw ... % ���������� �������� ����Ŀ��� ���
    = ReadParameterValue(fid,'khw',NUMERIC); 
mhw ... % ���������� �������� ����Ŀ��� ����
    = ReadParameterValue(fid,'mhw',NUMERIC);
khd ... % ���������� ���ɰ��� ����Ŀ��� ���
    = ReadParameterValue(fid,'khd',NUMERIC); 
mhd ... % ���������� ���ɰ��� ����Ŀ��� ����
    = ReadParameterValue(fid,'mhd',NUMERIC);

%--------------------------------------------------------------------------
% ��õ �ۿ�

FLUVIALPROCESS_COND ... % flooded region�� �� ������ �β� ��ȭ���� �����ϴ� ���
    = ReadParameterValue(fid,'FLUVIALPROCESS_COND',NUMERIC);
% * ����: ���� ����(AS^2 > ������ ��)�� ������ ��� ��õ�̶� ������
%   ������ : Montgomery and Dietrich (1992)
% * ����: 2�� 5õ ������ �������� ����õ �ֻ�� ���� ��õ�� ���� ������
%   AS^2�� 28351, ��ź� �ϴ�� 6319�� ������ ŭ. ������ �� ���� ��������
%   �ϸ� ���� �ʱ⿡ ��õ�� �ߴ����� �ʰ� �װ��� ��ӵǴ� ������ �߻���.
%   �߿����� ����� �������� �ɰ ��� Ȯ���� ��� ������ 30 ������.
%   ���� 100 ������ ����ϰ� ����. ���� �߿����縦 ���� ������ ������
channelInitiation ...           % ��õ ���� ���� �Ӱ谪
	= ReadParameterValue(fid,'channelInitiation',NUMERIC);
criticalUpslopeCellsNo ...      % ��õ ���� �Ӱ� ������� �� ����
	= ReadParameterValue(fid,'criticalUpslopeCellsNo',NUMERIC);
mfa ...                         % ��õ�� ���� ������ ��� ���Ŀ��� ������ ����
    = ReadParameterValue(fid,'mfa',NUMERIC); 
nfa ...                         % ��õ�� ���� ������ ��� ���Ŀ��� ����� ����
    = ReadParameterValue(fid,'nfa',NUMERIC); 
fSRho ...                       % ��ݵǴ� �������� ��� �е�
    = ReadParameterValue(fid,'fSRho',NUMERIC); 
fSD50 ...                       % ��ݵǴ� �������� �߰� �԰�
    = ReadParameterValue(fid,'fSD50',NUMERIC); 
eta ...                         % ��ݵǴ� �������� ��� ������
    = ReadParameterValue(fid,'eta',NUMERIC); 
nA ...                          % ���� ��õ �ϵ������� Manning ���� ���
    = ReadParameterValue(fid,'nA',NUMERIC); 
mfb ...                         % ��ݾ� �ϻ� ħ�� ���Ŀ��� ������ ����
    = ReadParameterValue(fid,'mfb',NUMERIC);
nfb ...                         % ��ݾ� �ϻ� ħ�� ���Ŀ��� ����� ����
    = ReadParameterValue(fid,'nfb',NUMERIC);
kfbre ...                       % ��ݾ� �ϻ� ���൵
    = ReadParameterValue(fid,'kfbre',NUMERIC); 
nB ...                          % ��ݾ� �ϻ� �ϵ������� Manning ���� ���
    = ReadParameterValue(fid,'nB',NUMERIC); 

%--------------------------------------------------------------------------
% parameterValuesFile�� �ݴ´�.
fclose(fid);

end % LoadParameterValues end
