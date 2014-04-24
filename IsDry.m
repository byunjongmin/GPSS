% =========================================================================
%> @section INTRO IsDry
%>
%> - ���� ���� ���� �̿� ���� flood ���¸� Ȯ���Ͽ�, 1) ������ ���ǵǾ� �ְų�
%>   �Ǵ� SINK�� ��� true�� ��ȯ�ϰ�, 2) ���� ó�� ���� flooded region�� ���
%>   false�� ��ȯ�ϴ� �Լ�
%>  - 3) ���� ���ǵ� �ƴ϶�� OLD_FLOODED�� �ش��ϴ� ����ε�, �� ��쵵
%>    ���� ���� ���� ���ⱸ�� �� �� �����Ƿ� true�� ��ȯ�Ѵ�.\n
%>    ������ ���� ó���� flooded region�� ���ⱸ�� ���� ���� ���� ���� ����
%>    ���ٸ� ������ �߻��Ѵ�.
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval isTrue   : ���� ���� ���� �̿� ���� flooded region�� �ƴѰ��� ����Ű�� ����
%>
%> @param nbrY      : ���� ���� ���� �̿� �� Y ��ǥ
%> @param nbrX      : ���� ���� ���� �̿� �� X ��ǥ
%> @param lowestY   : ���� ���� ���� Y ��ǥ
%> @param lowestX   : ���� ���� ���� X ��ǥ
%> @param flood     : SINK�� ���� ���� ���̴� ����(flooded region)
%> @param SDSNbrY   : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� Y ��ǥ
%> @param SDSNbrX   : �ִ��Ϻΰ�� ������ ����Ű�� ���� ���� X ��ǥ
%> @param elev      : ��ǥ �� [m]
% =========================================================================
function isTrue = IsDry(nbrY,nbrX,lowestY,lowestX,flood,SDSNbrY,SDSNbrX,elev)
%
%

% ��� ����
UNFLOODED = 0;
FLOODED = 1;
SINK = 3; 

% ���� ���� ���� �̿� ���� ������ ���ǵǾ� �ְų� SINK�� ���, true�� ��ȯ��
if ( ( flood(nbrY,nbrX) == UNFLOODED) || ( flood(nbrY,nbrX) == SINK) )

    isTrue = true;

% ���� flooded region�� �ش��Ѵٸ� false�� ��ȯ��
elseif ( flood(nbrY,nbrX) == FLOODED )

    isTrue = false;

% ���� ���� ó���� flooded region�� �ش��Ѵٸ�
else

    % �̿� ���� ���ⱸ �·Ḧ Ȯ���Ͽ�
    outletY = SDSNbrY(nbrY,nbrX);
    outletX = SDSNbrX(nbrY,nbrX);

    % ���� ��, �� ���� ó���� flooded region�� ���ⱸ�� ����
    % ���� ���� ���� ���� ������ ��� false�� ��ȯ�Ѵ�.
    if ( elev(outletY,outletX) == elev(lowestY,lowestX) )

        isTrue = false;

    else

        isTrue = true;

    end

end

end % IsDry end