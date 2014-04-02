% =========================================================================
%> @section INTRO IsDry
%>
%> - 가장 낮은 셀의 이웃 셀의 flood 상태를 확인하여, 1) 유향이 정의되어 있거나
%>   또는 SINK인 경우 true를 반환하고, 2) 현재 처리 중인 flooded region인 경우
%>   false를 반환하는 함수
%>  - 3) 위의 조건도 아니라면 OLD_FLOODED에 해당하는 경우인데, 이 경우도
%>    가장 낮은 셀이 유출구가 될 수 있으므로 true를 반환한다.\n
%>    하지만 과거 처리한 flooded region의 유출구의 고도가 가장 낮은 셀의 고도와
%>    같다면 문제가 발생한다.
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval isTrue   : 가장 낮은 셀의 이웃 셀이 flooded region이 아닌가를 가리키는 변수
%>
%> @param nbrY      : 가장 낮은 셀의 이웃 셀 Y 좌표
%> @param nbrX      : 가장 낮은 셀의 이웃 셀 X 좌표
%> @param lowestY   : 가장 낮은 셀의 Y 좌표
%> @param lowestX   : 가장 낮은 셀의 X 좌표
%> @param flood     : SINK로 인해 물이 고이는 지역(flooded region)
%> @param SDSNbrY   : 최대하부경사 유향이 가리키는 다음 셀의 Y 좌표
%> @param SDSNbrX   : 최대하부경사 유향이 가리키는 다음 셀의 X 좌표
%> @param elev      : 지표 고도 [m]
% =========================================================================
function isTrue = IsDry(nbrY,nbrX,lowestY,lowestX,flood,SDSNbrY,SDSNbrX,elev)
%
%

% 상수 정의
UNFLOODED = 0;
FLOODED = 1;
SINK = 3; 

% 가장 낮은 셀의 이웃 셀이 유향이 정의되어 있거나 SINK일 경우, true를 반환함
if ( ( flood(nbrY,nbrX) == UNFLOODED) || ( flood(nbrY,nbrX) == SINK) )

    isTrue = true;

% 만약 flooded region에 해당한다면 false를 반환함
elseif ( flood(nbrY,nbrX) == FLOODED )

    isTrue = false;

% 만약 과거 처리한 flooded region에 해당한다면
else

    % 이웃 셀의 유출구 좌료를 확인하여
    outletY = SDSNbrY(nbrY,nbrX);
    outletX = SDSNbrX(nbrY,nbrX);

    % 이의 고도, 즉 과거 처리한 flooded region의 유출구의 고도와
    % 가장 낮은 셀의 고도가 동일한 경우 false를 반환한다.
    if ( elev(outletY,outletX) == elev(lowestY,lowestX) )

        isTrue = false;

    else

        isTrue = true;

    end

end

end % IsDry end