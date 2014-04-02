% =========================================================================
%> @section INTRO DefineChannel
%>
%> - 하천에의한 물질운반이 발생하는 하도를 포함하는 셀을 정의하는 함수
%>
%> - Histroy
%>  - 2011-10-13
%>   - GPSSMain과 LoadParameterValues 그리고 AnalyseResult 함수에서 이용됨
%>
%> @callgraph
%> @callergraph
%> @version 1.82
%> @see 
%> 
%> @retval channel	                    : 하도를 포함하는 셀
%>
%> @param upslopeArea                       : 상부유역면적
%> @param integratedSlope                   : 수정된 (무한유향 알고리듬) 경사
%> @param channelInitation                  : 하천시작지점 임계 값
%> @param CELL_AREA                         : 셀 면적
%> @param criticalUpslopeCellsNo            : 하천시작지점의 상부유역 셀 임계 개수
%> @param FLOODED                           : flooded region
% =========================================================================
function channel = DefineChannel(upslopeArea,integratedSlope,channelInitiation,CELL_AREA,criticalUpslopeCellsNo,flood,FLOODED)
%
% function DefineChannel
%

channel ...
	= ((upslopeArea .* integratedSlope .^ 2 > channelInitiation) ... 	% 하천시작임계 값을 넘은 셀
	& (integratedSlope ~= -inf)) ... 					% 초기 경사값은 제외함
	| (upslopeArea / CELL_AREA) > criticalUpslopeCellsNo ... 		% 초기 지형이 평탄하여 하도가 형성되지 않을 경우를 대비한 초기지형 하도 형성 조건
	| (flood == FLOODED); 