% =========================================================================
%> @section INTRO CalcSDSFlow
%>
%> - �ִ� �Ϻ� ��縦 ������ �̿� ���� ã�� ���� ����� ��縦 ��ȯ�ϰ�, 
%>   �� �̿� ���� ��ǥ�� SDSNbrX, SDSNbrY�� ����ϴ� �Լ�.
%>
%>  - ������ CalcInfinitiveFlow �Լ��� ���� ����(�迭) ������ ������.
%>
%> @version 0.1
%>
%> @callgraph
%> @callergraph
%>
%> @retval steepestDescentSlope         : ���
%> @retval slopeAllNbr                  : 8�� �̿� ������ ���
%> @retval SDSFlowDirection             : ����
%> @retval SDSNbrY                      : ���� �� Y ��ǥ��
%> @retval SDSNbrX                      : ���� �� X ��ǥ��
%>
%> @param mRows                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param nCols                         : ���� (�ܰ� ��� ����) ���� �� ����
%> @param Y                             : �ܰ� ��踦 ������ Y�� ũ��
%> @param X                             : �ܰ� ��踦 ������ X�� ũ��
%> @param Y_INI                         : ���� ���� Y ���� ��ǥ��(=2)
%> @param Y_MAX                         : ���� ���� Y ������ ��ǥ��(=Y+1)
%> @param X_INI                         : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                         : ���� ���� X ������ ��ǥ��(=X+1)
%> @param Y_TOP_BND                     : ���� �ܰ� �� ��� Y ��ǥ��
%> @param Y_BOTTOM_BND                  : ���� �ܰ� �Ʒ� ��� Y ��ǥ��
%> @param X_LEFT_BND                    : ���� �ܰ� �� ��� X ��ǥ��
%> @param X_RIGHT_BND                   : ���� �ܰ� �� ��� X ��ǥ��
%> @param QUARTER_PI                    : pi * 0.25
%> @param DISTANCE_RATIO_TO_NBR         : �� ũ�⸦ �������� �̿� ���� �Ÿ��� [m]
%> @param elev                          : ��ǥ �� [m]
%> @param dX                            : �� ũ�� [m]
%> @param IS_LEFT_RIGHT_CONNECTED       : �¿� �ܰ� ��� ������ ����
%> @param ithNbrYOffset                 : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� Y�� �ɼ�
%> @param ithNbrXOffset                 : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� X�� �ɼ�
%> @param sE0LinearIndicies             : �ܰ� ��踦 ������ �߾� ��
%> @param s3IthNbrLinearIndicies        : 8 ���� �̿� ���� ����Ű�� 3���� ���� �迭
% =========================================================================
function [steepestDescentSlope,slopeAllNbr,SDSFlowDirection,SDSNbrY,SDSNbrX] = CalcSDSFlow(mRows,nCols,Y,X,Y_INI,Y_MAX,X_INI,X_MAX,Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,DISTANCE_RATIO_TO_NBR,elev,dX,IS_LEFT_RIGHT_CONNECTED,ithNbrYOffset,ithNbrXOffset,sE0LinearIndicies,s3IthNbrLinearIndicies)
%
% function CalcSDSFlow
%

% ���� �� ��� ���� �ʱ�ȭ
SDSFlowDirection = nan(mRows,nCols);
steepestDescentSlope = nan(mRows,nCols);
slopeAllNbr = nan(mRows,nCols,8);
% �ִ� �Ϻ� ��縦 ������ �̿� ���� ��ǥ�� ����ϴ� ��� �ʱ�ȭ
[SDSNbrX,SDSNbrY] = meshgrid(X_LEFT_BND:X_RIGHT_BND,Y_TOP_BND:Y_BOTTOM_BND);
% * ���� : ������ ���� ������ ����Ǵµ� �� ���� ���θ��� ������� �ϱ� ������
%   ��踦 ������ �迭�� �����ϰ� �ʱ�ȭ�Ѵ�. s�� mRows*nCols���� ���� Y*X
%   ũ�⸦ ������ ����� �ǹ��Ѵ�.
sSteepestDescentSlope = -inf(Y, X);
% ������ ���� ��쿡�� NaN���� ��ϵȴ�.
sSDSFlowDirection = nan(Y, X);
[sSDSNbrX,sSDSNbrY] = meshgrid(X_INI:X_MAX,Y_INI:Y_MAX);

% ���� ������ ������ �����Ͽ� ����� ��縦 ���ϴ� ���� �ƴ϶�,
% ����(�迭) ������ ������ �����Ѵ�.

% �߾� ���� (���� ������ ����Ű��) ���� �����Ѵ�.
sE0Elevation = elev(sE0LinearIndicies);

% �߾� ���� �������� 8�� �̿� ���� ��縦 Ž���Ͽ� ����� ��縦 �����Ѵ�.

% �ִ� �Ϻ� ��縦 ������ �̿� ���� Y,X ��ǥ�� �Է½� �⺻�� �Ǵ� ��ǥ��
initialNbrX = sSDSNbrX;
initialNbrY = sSDSNbrY;

for ithNbr = 1:8

    % ���� �ɼ��� �̿��� k ��° �̿� ���� ��
    sKthNbrElevation = elev(s3IthNbrLinearIndicies(:,:,ithNbr));

    % �߾� ���� k ��° �̿� ������ ��縦 ����
    sKthNbrSlope = (sE0Elevation - sKthNbrElevation) ...
    / (DISTANCE_RATIO_TO_NBR(ithNbr) * dX);

    % ���ĸ� ���� k ��° �̿� ������ ��縦 ������
    slopeAllNbr(Y_INI:Y_MAX,X_INI:X_MAX, ithNbr) = sKthNbrSlope;

    % k ��° �̿� ������ ��簡 ���� �ִ� ��纸�� ū ������
    % biggerSlope���� �����
    biggerSlope = sKthNbrSlope > sSteepestDescentSlope;

    % biggerSlope�� �ش��ϴ� ������ �������
    % k ��° �̿� ���� ��ǥ�� sSDSNbrY, sSDSNbrX�� �����

    % �¿찡 ����Ǿ����� Ȯ���ϰ�, ����Ǿ��ٸ� offset �� �缳���Ѵ�.
    if IS_LEFT_RIGHT_CONNECTED == true
        
        if ithNbr == 1 || ithNbr == 2 || ithNbr == 8
            
            ithNbrXOffset2 = ones(Y,X);
            ithNbrXOffset2(:,X) = ithNbrXOffset2(:,X) - X;
            
            sSDSNbrY(biggerSlope) = initialNbrY(biggerSlope) ...
                + ithNbrYOffset(ithNbr);
            sSDSNbrX(biggerSlope) = initialNbrX(biggerSlope) ...
                + ithNbrXOffset2(biggerSlope);
            
        elseif ithNbr == 4 || ithNbr == 5 || ithNbr == 6
            
            ithNbrXOffset2 = - ones(Y,X);
            ithNbrXOffset2(:,1) = ithNbrXOffset2(:,1) + X;
            
            sSDSNbrY(biggerSlope) = initialNbrY(biggerSlope) ...
                + ithNbrYOffset(ithNbr);
            sSDSNbrX(biggerSlope) = initialNbrX(biggerSlope) ...
                + ithNbrXOffset2(biggerSlope);
            
        else % ithNbr == 3 || ithNbr == 7
        
            sSDSNbrY(biggerSlope) = initialNbrY(biggerSlope) ...
                + ithNbrYOffset(ithNbr);
            sSDSNbrX(biggerSlope) = initialNbrX(biggerSlope) ...
                + ithNbrXOffset(ithNbr);
        
        end

    
    else
        
        sSDSNbrY(biggerSlope) = initialNbrY(biggerSlope) ...
            + ithNbrYOffset(ithNbr);
        sSDSNbrX(biggerSlope) = initialNbrX(biggerSlope) ...
            + ithNbrXOffset(ithNbr);
        
    end
    
    % k ��° �̿����� ��簡 ���� ���� possitiveSlope�̶�� ����Ѵ�.
    possitiveSlope = sKthNbrSlope > 0;

    % k ��° �̿� ������ ��簡 ���̸鼭 ���ÿ� ���� �ִ� ��纸�� ū ������
    % k ��° �̿� ���� ������ �������� ����Ѵ�.
    sSDSFlowDirection(biggerSlope & possitiveSlope) ...
      = (ithNbr-1) * QUARTER_PI;

    % k ��° �̿� ������ ��縦 ���� ����Ѵ�.
    sSteepestDescentSlope(biggerSlope) = sKthNbrSlope(biggerSlope);

end % for ithNbr = 1:8

% �ִ� �Ϻ� ��� ����� ����� ��谪�� �����Ѵ�.
% �� ���� ����� ����� ���� NaN���� ��ϵȴ�.
SDSFlowDirection(Y_INI:Y_MAX,X_INI:X_MAX) = sSDSFlowDirection;
steepestDescentSlope(Y_INI:Y_MAX,X_INI:X_MAX) = sSteepestDescentSlope;
SDSNbrX(Y_INI:Y_MAX,X_INI:X_MAX) = sSDSNbrX;
SDSNbrY(Y_INI:Y_MAX,X_INI:X_MAX) = sSDSNbrY;

end % CalcSDSFlow end