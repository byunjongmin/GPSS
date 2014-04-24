% =========================================================================
%> @section INTRO FindSDSDryNbr
%>
%> - ���� ���� ���� �̿� ���� Ž���Ͽ� �̿� �� �� flooded region�� ������ �ʰ�
%>   ������ �ʰ� ���ÿ� �ִ� �Ϻ� ��縦 ������ �̿� ���� �ִٸ� ���� ���� ����
%>   ���� ������ �����ϰ� ������ �����ϴ� �̿� ���� ���ٸ� ���ⱸ�� ���ٰ�
%>   ��ȯ�ϴ� �Լ�
%>
%>  - �ֿ� �˰���
%>   -  ���� ���� ���� �ֺ� �̿� ������ Ž���Ͽ�, ���� ó�� ���� flooded
%>      region�� �ش����� �����鼭, �Ϻ� ��簡 ���� ū ���� ã��
%>   -  �� ������ �����ϴ� �̿� ���� �����Ѵٸ� ������ �۾��� ������
%>    -  1) �� ������ �����ϴ� ������ ��縦 ���� ���� ���� ���� ����
%>    -  2) �� �̿� ���� ��ǥ�� ���� ���� ���� SDSNbrY,SDSNbrX�� ���
%>    -  3) ���� ���� ���� �ִ� �Ϻ� ��� ���⵵ �� �̿� ���� ����Ű���� ����
%>    -  4) �������� ���ⱸ�� ã�Ҵٰ� ��ȯ
%>     - �߿��� ���� ���� ���� ��(���ⱸ�� �� ��)�� ���� ������ ���������ν�,
%>       ������ flooded region�� ������ ���� �𸣴� ������ flooded region
%>       �ܺη� ���ϵ��� ����� �� �ִٴ� ��.
%>   -  ������ �����ϴ� ���� �������� �ʴ´ٸ�, ���ⱸ�� ã�� ���ߴٰ� ��ȯ��
%>   - 	���� ���� ���� �̿� ���� �� ���� ��迡 �ش��� ���, flood�� ����
%>      ���� UNFLOODED ���°� �⺻���̱� ������ IsDry�� true�� ��ȯ��.
%>      ������ �� ���� ����� ���� �� ���� ���κ��� ���� ������, ����
%>      ���� ���� �Ϻ� ��縦 ������ ����. �ᱹ �� ���� ��迡 �ִ� �̿� ����
%>      ���ⱸ�� �ش����� ����. ���� ���� ���� ���� �� ���� ��迡 ������
%>      ���̶��, ���� �帧�� ��� ���� �귯���� �Ȱ�, �� ���� ���η�
%>      ���� ������ ������ �� ����
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval SDSNbrY                  : ������ ���� ���� Y ��ǥ��
%> @retval SDSNbrX                  : ������ ���� ���� X ��ǥ��
%> @retval SDSFlowDirection         : ������ ����
%> @retval steepestDescentSlope     : ������ ���
%> @retval integratedSlope          : ������ facet flow ���
%> @retval isTrue                   : ���ⱸ ����
%>
%> @param X_INI                     : ���� ���� X ���� ��ǥ��(=2)
%> @param X_MAX                     : ���� ���� X ������ ��ǥ��(=X+1)
%> @param X_LEFT_BND                : ���� �ܰ� �� ��� X ��ǥ��
%> @param X_RIGHT_BND               : ���� �ܰ� �� ��� X ��ǥ��
%> @param QUARTER_PI                : pi * 0.25
%> @param lowestY                   : flooded region ��迡�� ������ �����ϴ� ���� Y ��ǥ��
%> @param lowestX                   : flooded region ��迡�� ������ �����ϴ� ���� Y ��ǥ��
%> @param elev                      : ��ǥ �� [m]
%> @param slopeAllNbr               : 8 �̿� ������ ��� [radian]
%> @param SDSNbrY                   : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX                   : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param SDSFlowDirection          : �ִ��Ϻΰ�� ����
%> @param flood                     : SINK�� ���� ���� ���̴� ����(flooded region)
%> @param steepestDescentSlope      : �ִ��Ϻΰ��
%> @param integratedSlope           : facet flow ���
%> @param ithNbrYOffset             : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� Y�� �ɼ�
%> @param ithNbrXOffset             : �߾� ���� ���� 8 ���� �̿� ���� ����Ű�� ���� X�� �ɼ�
%> @param IS_LEFT_RIGHT_CONNECTED   : �¿� �ܰ� ��� ������ ����
% =========================================================================
function [SDSNbrY,SDSNbrX,SDSFlowDirection,steepestDescentSlope,integratedSlope,isTrue] = FindSDSDryNbr(X_INI,X_MAX,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,lowestY,lowestX,elev,slopeAllNbr,SDSNbrY,SDSNbrX,SDSFlowDirection,flood,steepestDescentSlope,integratedSlope,ithNbrYOffset,ithNbrXOffset,IS_LEFT_RIGHT_CONNECTED)
%
% function FindSDSDryNbr
%

% �ִ� �Ϻ� ��縦 ������ �̿� ���� ã�� ���� ���� ��� ����
steeperSlope = -inf;

% ���� ���� ���� ���� �̿� ������ �ݽð� �������� Ž���Ͽ�,
% �̿� ������ ��簡 ���� ��纸�� ũ�� ���ÿ�
% ���� ó�� ���� flooded region�� �ش����� �ʴ´ٸ�
% steeperSlope�� ��簪�� �����ϰ�, SDSNbrY,SDSNbrX�� �����Ѵ�.

for ithNbr = 1:8
    
    nbrY = lowestY + ithNbrYOffset(ithNbr);
    nbrX = lowestX + ithNbrXOffset(ithNbr);
    
    if IS_LEFT_RIGHT_CONNECTED == true
        
        if nbrX == X_LEFT_BND
            
            nbrX = X_MAX;
            
        elseif nbrX == X_RIGHT_BND
            
            nbrX = X_INI;
            
        end
        
    end

    if ( ( slopeAllNbr(lowestY,lowestX,ithNbr) > steeperSlope ) && ...
        IsDry(nbrY,nbrX,lowestY,lowestX,flood,SDSNbrY,SDSNbrX,elev) )

        steeperSlope = slopeAllNbr(lowestY,lowestX,ithNbr);
        % * ����: SDSNbrY,SDSNbrX�� �Ʒ��� ����������, steeperSlope <= 0 ��
        %   ��쿡 false�� ��ȯ�Ǿ� (lowestY,lowest)�� flooded region��
        %   ���ⱸ�� ���� ���ϰ� flooded region�� �ȴ�. ���� ���⼭ ������
        %   SDSNbrY,SDSNbrX�� ���ⱸ�� ã�� �Ǹ� �ٽ� �����ȴ�.
        SDSNbrY(lowestY,lowestX) = nbrY;
        SDSNbrX(lowestY,lowestX) = nbrX;
        steepestDryNbr = ithNbr;
    
    end
    
end

% ���� �������� steeperSlope�� ���� ���� ���� ��쿡��
if (steeperSlope <= 0)

    isTrue = false;

else
    
    % �ִ� �Ϻ� ��縦 steeperSlope���� �����ϰ�
    steepestDescentSlope(lowestY,lowestX) = steeperSlope;
    
    % �̸� integratedSlope���� �ݿ��Ѵ�.
    integratedSlope(lowestY,lowestX) = steeperSlope;
    
    % ���⵵ ������ �����ϴ� �̿� ���� ����Ű���� �����ϰ�
    SDSFlowDirection(lowestY,lowestX) = (steepestDryNbr - 1) * QUARTER_PI;
    
    % true�� ��ȯ�Ѵ�.
    isTrue = true;

end

end % FindSDSDryNbr end