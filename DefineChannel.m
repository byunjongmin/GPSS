% =========================================================================
%> @section INTRO DefineChannel
%>
%> - ��õ������ ��������� �߻��ϴ� �ϵ��� �����ϴ� ���� �����ϴ� �Լ�
%>
%> - Histroy
%>  - 2011-10-13
%>   - GPSSMain�� LoadParameterValues �׸��� AnalyseResult �Լ����� �̿��
%>
%> @callgraph
%> @callergraph
%> @version 1.82
%> @see 
%> 
%> @retval channel	                    : �ϵ��� �����ϴ� ��
%>
%> @param upslopeArea                       : �����������
%> @param integratedSlope                   : ������ (�������� �˰���) ���
%> @param channelInitation                  : ��õ�������� �Ӱ� ��
%> @param CELL_AREA                         : �� ����
%> @param criticalUpslopeCellsNo            : ��õ���������� ������� �� �Ӱ� ����
%> @param FLOODED                           : flooded region
% =========================================================================
function channel = DefineChannel(upslopeArea,integratedSlope,channelInitiation,CELL_AREA,criticalUpslopeCellsNo,flood,FLOODED)
%
% function DefineChannel
%

channel ...
	= ((upslopeArea .* integratedSlope .^ 2 > channelInitiation) ... 	% ��õ�����Ӱ� ���� ���� ��
	& (integratedSlope ~= -inf)) ... 					% �ʱ� ��簪�� ������
	| (upslopeArea / CELL_AREA) > criticalUpslopeCellsNo ... 		% �ʱ� ������ ��ź�Ͽ� �ϵ��� �������� ���� ��츦 ����� �ʱ����� �ϵ� ���� ����
	| (flood == FLOODED); 