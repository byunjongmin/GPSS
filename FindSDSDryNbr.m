% =========================================================================
%> @section INTRO FindSDSDryNbr
%>
%> - 가장 낮은 셀의 이웃 셀을 탐색하여 이웃 셀 중 flooded region에 속하지 않고
%>   속하지 않고 동시에 최대 하부 경사를 가지는 이웃 셀이 있다면 가장 낮은 셀의
%>   경사와 유향을 변경하고 조건을 만족하는 이웃 셀이 없다면 유출구가 없다고
%>   반환하는 함수
%>
%>  - 주요 알고리듬
%>   -  가장 낮은 셀의 주변 이웃 셀들을 탐색하여, 현재 처리 중인 flooded
%>      region에 해당하지 않으면서, 하부 경사가 가장 큰 셀을 찾음
%>   -  이 조건을 만족하는 이웃 셀이 존재한다면 다음의 작업을 수행함
%>    -  1) 이 조건을 만족하는 셀과의 경사를 가장 낮은 셀의 경사로 정의
%>    -  2) 이 이웃 셀의 좌표를 가장 낮은 셀의 SDSNbrY,SDSNbrX에 기록
%>    -  3) 가장 낮은 셀의 최대 하부 경사 유향도 이 이웃 셀을 가리키도록 정의
%>    -  4) 실질적인 유출구를 찾았다고 반환
%>     - 중요한 것은 가장 낮은 셀(유출구가 될 셀)의 경사와 유향을 변경함으로써,
%>       기존에 flooded region을 향했을 지도 모르는 유향이 flooded region
%>       외부로 향하도록 변경될 수 있다는 점.
%>   -  조건을 만족하는 셀이 존재하지 않는다면, 유출구를 찾지 못했다고 반환함
%>   - 	가장 낮은 셀의 이웃 셀이 모델 영역 경계에 해당할 경우, flood의 영역
%>      경계는 UNFLOODED 상태가 기본값이기 때문에 IsDry는 true를 반환함.
%>      하지만 모델 영역 경계의 고도가 모델 영역 내부보다 높기 때문에, 가장
%>      낮은 셀과 하부 경사를 만들지 않음. 결국 모델 영역 경계에 있는 이웃 셀은
%>      유출구에 해당하지 않음. 따라서 가장 낮은 셀이 모델 영역 경계에 인접한
%>      셀이라면, 이의 흐름은 적어도 경계로 흘러가지 안고, 모델 영역 내부로
%>      향할 것으로 예측할 수 있음
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval SDSNbrY                  : 수정된 다음 셀의 Y 좌표값
%> @retval SDSNbrX                  : 수정된 다음 셀의 X 좌표값
%> @retval SDSFlowDirection         : 수정된 유향
%> @retval steepestDescentSlope     : 수정된 경사
%> @retval integratedSlope          : 수정된 facet flow 경사
%> @retval isTrue                   : 유출구 유무
%>
%> @param X_INI                     : 모형 영역 X 시작 좌표값(=2)
%> @param X_MAX                     : 모형 영역 X 마지막 좌표값(=X+1)
%> @param X_LEFT_BND                : 모형 외곽 좌 경계 X 좌표값
%> @param X_RIGHT_BND               : 모형 외곽 우 경계 X 좌표값
%> @param QUARTER_PI                : pi * 0.25
%> @param lowestY                   : flooded region 경계에서 조건을 만족하는 셀의 Y 좌표값
%> @param lowestX                   : flooded region 경계에서 조건을 만족하는 셀의 Y 좌표값
%> @param elev                      : 지표 고도 [m]
%> @param slopeAllNbr               : 8 이웃 셀과의 경사 [radian]
%> @param SDSNbrY                   : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX                   : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
%> @param SDSFlowDirection          : 최대하부경사 유향
%> @param flood                     : SINK로 인해 물이 고이는 지역(flooded region)
%> @param steepestDescentSlope      : 최대하부경사
%> @param integratedSlope           : facet flow 경사
%> @param ithNbrYOffset             : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 Y축 옵셋
%> @param ithNbrXOffset             : 중앙 셀로 부터 8 방향 이웃 셀을 가리키기 위한 X축 옵셋
%> @param IS_LEFT_RIGHT_CONNECTED   : 좌우 외곽 경계 연결을 결정
% =========================================================================
function [SDSNbrY,SDSNbrX,SDSFlowDirection,steepestDescentSlope,integratedSlope,isTrue] = FindSDSDryNbr(X_INI,X_MAX,X_LEFT_BND,X_RIGHT_BND,QUARTER_PI,lowestY,lowestX,elev,slopeAllNbr,SDSNbrY,SDSNbrX,SDSFlowDirection,flood,steepestDescentSlope,integratedSlope,ithNbrYOffset,ithNbrXOffset,IS_LEFT_RIGHT_CONNECTED)
%
% function FindSDSDryNbr
%

% 최대 하부 경사를 가지는 이웃 셀을 찾기 위한 기준 경사 변수
steeperSlope = -inf;

% 가장 낮은 셀의 동쪽 이웃 셀부터 반시계 방향으로 탐색하여,
% 이웃 셀과의 경사가 이전 경사보다 크고 동시에
% 현재 처리 중인 flooded region에 해당하지 않는다면
% steeperSlope의 경사값을 갱신하고, SDSNbrY,SDSNbrX를 변경한다.

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
        % * 주의: SDSNbrY,SDSNbrX를 아래에 수정하지만, steeperSlope <= 0 인
        %   경우에 false가 반환되어 (lowestY,lowest)는 flooded region의
        %   유출구가 되지 못하고 flooded region이 된다. 따라서 여기서 수정된
        %   SDSNbrY,SDSNbrX는 유출구를 찾게 되면 다시 수정된다.
        SDSNbrY(lowestY,lowestX) = nbrY;
        SDSNbrX(lowestY,lowestX) = nbrX;
        steepestDryNbr = ithNbr;
    
    end
    
end

% 위의 과정에서 steeperSlope이 양의 값을 가질 경우에만
if (steeperSlope <= 0)

    isTrue = false;

else
    
    % 최대 하부 경사를 steeperSlope으로 정의하고
    steepestDescentSlope(lowestY,lowestX) = steeperSlope;
    
    % 이를 integratedSlope에도 반영한다.
    integratedSlope(lowestY,lowestX) = steeperSlope;
    
    % 유향도 조건을 만족하는 이웃 셀을 가리키도록 수정하고
    SDSFlowDirection(lowestY,lowestX) = (steepestDryNbr - 1) * QUARTER_PI;
    
    % true를 반환한다.
    isTrue = true;

end

end % FindSDSDryNbr end