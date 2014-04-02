% =========================================================================
%> @section INTRO CheckOversteepSlopes
%>
%> - Ȱ�� ����(õ��Ȱ��(shallow landsliding)�� ��ݾ�Ȱ��(bedrock
%>    landsliding))�� ���� �Ҿ����� ����� �ľ��ϴ� �Լ�.
%>
%> - History
%>  - 2010-12-21
%>   -RapidMassMovement �Լ��� Ȱ�� �߻�Ȯ�� ������ ������.
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%> @see RapidMassMovement()
%>
%> @retval oversteepSlopes              : �Ҿ����� ��
%> @retval oversteepSlopesIndicies      : (�������� ���ĵ�) �Ҿ����� �� ����
%> @retval dTAfterLastShallowLandslide  : ���ŵ� ������ õ��Ȱ�� ���� ��� �ð� [year]
%> @retval dTAfterLastBedrockLandslide  : ���ŵ� ������ ��ݾ�Ȱ�� ���� ��� �ð� [year]
%>
%> @param mRows                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param Y                             : �ܰ� ��踦 ������ Y�� ũ��
%> @param X                             : �ܰ� ��踦 ������ X�� ũ��
%> @param Y_INI                         : ���� ���� Y ���� ��ǥ��(=2)
%> @param Y_MAX                         : ���� ���� Y ������ ��ǥ��(=Y+1)
%> @param X_INI                         : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                         : ���� ���� X ������ ��ǥ��(=X+1)
%> @param dT                            : �������� �����Ⱓ [year]
%> @param ROOT2                         : sqrt(2)
%> @param rapidMassMovementType         : Ȱ�� ����
%> @param criticalSlopeForFailure       : Ȱ�� �߻� �Ӱ� ��鰢 [radian]
%> @param bedrockElev                   : ��ݾ� �� [m]
%> @param sedimentThick                 : ������ �β� [m]
%> @param elev                          : ��ǥ �� [m]
%> @param dTAfterLastShallowLandslide   : ������ õ��Ȱ�� ���� ��� �ð� [year]
%> @param dTAfterLastBedrockLandslide   : ������ ��ݾ�Ȱ�� ���� ��� �ð� [year]
%> @param dX                            : �� ũ�� [m]
%> @param OUTER_BOUNDARY                : ���� ���� �ܰ� ��� ����ũ
%> @param SDSNbrY                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX                       : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param flood                         : SINK�� ���� ���� ���̴� ����(flooded region)
% =========================================================================
function [oversteepSlopes,oversteepSlopesIndicies,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide] = CheckOversteepSlopes(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,dT,ROOT2,rapidMassMovementType,criticalSlopeForFailure,bedrockElev,sedimentThick,elev,dTAfterLastShallowLandslide,dTAfterLastBedrockLandslide,dX,OUTER_BOUNDARY,SDSNbrY,SDSNbrX,flood)
%
% function CheckOversteepSlopes
%

% ��� �ʱ�ȭ
FLOODED = 2; % flooded region �±�
% Ȱ�� ����
SOIL = 1;   % õ��Ȱ��
% ROCK = 2; % ��ݾ�Ȱ��

% ���� ����
% * ����: �ٽ� �ѹ� ����� �ʿ䰡 ����. ������ �ùķ��̼��� �ؼ� ��� ������
% Ȱ�� �߻� �󵵸� ���̴��� �ľ��� �ʿ䰡 ����.
minSedimentThickForInitiation = 0.1;    % [m] õ��Ȱ���� �߻��� �� �ִ� �ּ����� ������ �β�
shallowLandslideCharTime = 100;         % [year] õ��Ȱ���� �ٽ� �߻��ϴ� �����Ⱓ
bedrockLandslideCharTime = 100;         % [year] ��ݾ�Ȱ���� �ٽ� �߻��ϴ� �����Ⱓ

% 1. Ȱ�� ������ ���� �߻� �⺻ ������ �����ϴ� ���� ������ �ľ��ϰ� (�߻�Ȯ��
% �� �̵����� �����ϱ� ����) ��ȿ ���� ������
if rapidMassMovementType == SOIL

	% õ��Ȱ���� ���۵Ǵ� ���� ������ �β��� ������ �̻��̾����
    % * �̴� Ȱ�� �󵵰� ���������� ����Ѵٴ� ����� ��ü��. ������ �̴� ����
    %   Ȯ���� �ٰŰ� ����. �̸� ã�� ��� ������ ��. �׷��� �ϴ� 0.5�� ������
	preliminaryCellsIndicies ...
        = find(sedimentThick > minSedimentThickForInitiation ...
        & flood ~= FLOODED & ~ OUTER_BOUNDARY);
	
	% ��ǥ ���� ��ȿ ����
	effectiveElev = elev;
	
else

	% ��ݾ�Ȱ���� ������ �β��� ���þ���
	preliminaryCellsIndicies = find(flood ~= FLOODED & ~ OUTER_BOUNDARY);
	
	% ��ݾ� ���� ��ȿ ����
	effectiveElev = bedrockElev;
	
end

% 2. Ȱ�� �߻� Ȯ�� ���ϱ�
% * ����: Ȱ�� �߻� �Ӱ� �� ���̿� ������ Ȱ�� �߻� ���� ��� �ð��� �̿���

% 1) �⺻ ���� ���� ���� ���� �� ������ ����
preliminaryCellsNbrsY = SDSNbrY(preliminaryCellsIndicies);
preliminaryCellsNbrsX = SDSNbrX(preliminaryCellsIndicies);
preliminaryCellsNbrsIndicies ...
    = (preliminaryCellsNbrsX - 1)*mRows + preliminaryCellsNbrsY;

% 2) ���� �� ���⿡ ���� ������鰢�� �̷�� �� ����(���� critical height)�� ������

% (1) �̿� �� ���⿡ ���� critical height
criticalHeightForOrtho = criticalSlopeForFailure * dX;
criticalHeightForDiag = criticalSlopeForFailure * dX * ROOT2;

% (2) ���� �� ���⿡ ���� critical height
% - (�ϴ� �밢�� ���� critical height��) �ʱ�ȭ
criticalHeight = zeros(mRows,nCols);
criticalHeight(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = ones(Y,X) * criticalHeightForDiag;

% - ���� ���� ���� ������ ���� critical height
nbrIndicies = (SDSNbrX - 1) * mRows + SDSNbrY;      % ���� �� ����
indicies = reshape(1:mRows*nCols,[mRows,nCols]);    % �߾� �� ����
dIndicies = indicies - nbrIndicies;            % �߾� ���� ���� �� ���� ��
orthogonalDownstream = false(mRows,nCols);
orthogonalDownstream(Y_INI:Y_MAX,X_INI:X_MAX) ...
    = (mod(dIndicies(Y_INI:Y_MAX,X_INI:X_MAX),mRows) == 0) ...
    | (abs(dIndicies(Y_INI:Y_MAX,X_INI:X_MAX)) == 1);
criticalHeight(orthogonalDownstream) = criticalHeightForOrtho;

% 3) (������ �����ϴ� ���� �������) ���� ������ ������ ����
% * ����: ��ȿ���� �������� ��
downslopeDElev = zeros(mRows,nCols);
downslopeDElev(preliminaryCellsIndicies) ...
    = effectiveElev(preliminaryCellsIndicies) ...
    - elev(preliminaryCellsNbrsIndicies);

% 4) Ȱ�� ������ ���� Ȱ�� �߻� Ȯ���� ���ϰ�, Ȱ�� �߻� ���� ������ �ľ���

landslideProbability = zeros(mRows,nCols);  % Ȱ�� �߻� Ȯ�� �ʱ�ȭ

if rapidMassMovementType == SOIL
    
    % õ��Ȱ�� �߻� Ȯ��
    landslideProbability(preliminaryCellsIndicies) ...
        = (downslopeDElev(preliminaryCellsIndicies) ...
        ./ criticalHeight(preliminaryCellsIndicies) - 1) ...
        + dTAfterLastShallowLandslide(preliminaryCellsIndicies) ...
        / shallowLandslideCharTime;
    % * ����: ���� �Ӱ� �������� ���� ��� �߻�Ȯ���� 0��
    % * ����: �Ӱ� �������� Ŭ �� Ȱ���� �߻���
    landslideProbability(downslopeDElev - criticalHeight < 0) = 0;

    % õ��Ȱ�� �߻� �� ����
    oversteepSlopesIndicies = find(landslideProbability >= 1);
    
    % for debug
    [tmp1,tmp2] = size(oversteepSlopesIndicies);
    if tmp1 > 0
       
        3;
    
    end
    
    % ������ õ��Ȱ�� �߻� ���� ��� �ð�
    dTAfterLastShallowLandslide(landslideProbability > 0) ...
        = dTAfterLastShallowLandslide(landslideProbability > 0) + dT;
    
    dTAfterLastShallowLandslide(oversteepSlopesIndicies) = 0;
    
else

    % ��ݾ�Ȱ�� �߻� Ȯ��
    landslideProbability(preliminaryCellsIndicies) ...
        = (downslopeDElev(preliminaryCellsIndicies) ...
        ./ criticalHeight(preliminaryCellsIndicies) - 1) ...
        + dTAfterLastBedrockLandslide(preliminaryCellsIndicies) ...
        / bedrockLandslideCharTime;
    % * ����: ���� �Ӱ� �������� ���� ��� �߻�Ȯ���� 0��
    % * ����: �Ӱ� �������� Ŭ �� Ȱ���� �߻���
    landslideProbability(downslopeDElev - criticalHeight < 0) = 0;
    
    % ��ݾ�Ȱ�� �߻� �� ����
    oversteepSlopesIndicies = find(landslideProbability >= 1);
    
    % for debug
    [tmp1,tmp2] = size(oversteepSlopesIndicies);
    if tmp1 > 0
       
        3;
        
    end
    
    % ������ ��ݾ�Ȱ�� �߻� ���� ��� �ð�
    % * ����: õ��Ȱ���� ��� �ð��� 0���� ������
    dTAfterLastBedrockLandslide(landslideProbability > 0) ...
        = dTAfterLastBedrockLandslide(landslideProbability > 0) + dT;
    
    dTAfterLastBedrockLandslide(oversteepSlopesIndicies) = 0;
    dTAfterLastShallowLandslide(oversteepSlopesIndicies) = 0; % ����
    
    
end

% 3. Ȱ�� �߻� ���� ������ ����
oversteepSlopes = false(mRows,nCols);
oversteepSlopes(oversteepSlopesIndicies) = true;

% 4. Ȱ�� �߻� �� ������ �� ������ �迭��
oversteepSlopesElev = elev(oversteepSlopesIndicies);
sortedOversteepSlopes = [oversteepSlopesIndicies oversteepSlopesElev];
sortedOversteepSlopes = sortrows(sortedOversteepSlopes,-2);
oversteepSlopesIndicies = sortedOversteepSlopes(:,1);

end % CheckOversteepSlopes end