function ...
[dSedimentThick ...      % 퇴적층 두께 변화율 [m^3/m^2 subDT]
,dBedrockElev ...        % 기반암 고도 변화율 [m^3/m^2 subDT]
,dChanBedSed ...         % 하도 내 하상 퇴적물 변화율 [m^3/subDT]
,inputFlux ...           % 상부 유역으로 부터의 유입율 [m^3/subDT]
,outputFlux...           % 하류로의 유출율 [m^3/subDT]
,inputFloodedRegion ...  % flooded region으로의 유입율 [m^3/subDT]
,isFilled] ...           % 상부 유입으로 인한 flooded region의 매적 유무
= EstimateDElevByFluvialProcess_m ...
(dX ...                         % 셀 크기
,mRows ...
,nCols ...
,consideringCellsNo ...         % 하천작용이 발생하는 셀 수
,sortedYXElev ... 		        % 고도순으로 정렬된 Y,X 좌표
,e1LinearIndicies ...           % 다음 셀 색인
,e2LinearIndicies ...           % 다음 셀 색인
,outputFluxRatioToE1 ...        % 다음 셀로의 유출 비율
,outputFluxRatioToE2 ...        % 다음 셀로의 유출 비율
,SDSNbrY ...                    % 다음 셀 색인
,SDSNbrX ...                    % 다음 셀 색인
,flood ...                      % flooded region
,floodedRegionCellsNo ...       % flooded region 구성 셀 수
,floodedRegionStorageVolume ... % flooded region 저장량
,transportCapacity ...          % 최대 퇴적물 운반능력
,bedrockIncision ...			% 기반암 하상 침식율
,chanBedSed ...                 % 하도내 하상 퇴적층 부피
,bedrockElev ...				% 기반암 고도
,sedimentThick ...              % 퇴적층 두께
,hillslope ...                  % 사면 셀
,transportCapacityForShallow ...% 지표유출로 인한 물질이동
,elev) %#codegen

% define constants
FLOODED = 2;
CELL_AREA = dX * dX;

% define output variables
dSedimentThick = zeros(mRows,nCols);    % 퇴적물 두께 변화율 [m^3/m^2 subDT]
dBedrockElev = zeros(mRows,nCols);  % 기반암 고도 변화율 [m^3/m^2 subDT]
dChanBedSed = zeros(mRows,nCols);   % 기반암 고도 변화율 [m^3/m^2 subDT]
inputFlux = zeros(mRows,nCols);     % 상부 유역으로부터의 유입량 [m^3/subDT]
outputFlux = zeros(mRows,nCols);    % 유향을 따라 다음 셀로의 유출량 [m^3/subDT]
inputFloodedRegion = zeros(mRows,nCols); % flooded region으로의 유입량[m^3/subDT]
isFilled = false(mRows,nCols);      % flooded region으로의 유입량이 저장량을 초과했는지 표시하는 태그

% (높은 고도 순으로) 하천작용에 의한 퇴적물 두께 및 기반암 고도 변화율을 구함
for iCell = 1:consideringCellsNo

	% 1. i번째 셀 색인
	iCellY = sortedYXElev(iCell,1);
	iCellX = sortedYXElev(iCell,2);

	% 2. i번째 셀의 유출률을 구하고 이를 유향을 따라 다음 셀에 분배함

	% 1) i번째 셀이 flooded region 유출구인지를 확인함	
	if floodedRegionCellsNo(iCellY,iCellX) == 0
    
		% 유출구가 아니라면 (일반적임), 지표유출 및 하천에 의한 유출량을
		%  구하고 이를 무한 유향을 따라 다음 셀에 분배함
		
		% (1) i번째 셀이 사면인지를 확인함
        if hillslope(iCellY,iCellX) == true

			% A. 사면이라면, 지표유출에 의한 침식률을 구함
			outputFlux(iCellY,iCellX) = transportCapacityForShallow(iCellY,iCellX);
			dSedimentThick(iCellY,iCellX) ...
				= (inputFlux(iCellY,iCellX) - outputFlux(iCellY,iCellX)) / CELL_AREA;

			% to do: 기반암 고도에는 영향을 주지 않는 것으로 처리함
			if sedimentThick(iCellY,iCellX) + dSedimentThick(iCellY,iCellX) < 0
				dSedimentThick(iCellY,iCellX) = -sedimentThick(iCellY,iCellX);
                outputFlux(iCellY,iCellX) = sedimentThick(iCellY,iCellX) * CELL_AREA;
			end

		else
			
			% B. 하천이라면, 하천작용에 의한 유출률을 구하고 이를 다음 셀에 분배함
            
			% A) 퇴적물 운반능력[m^3/subDT]이 하도 내 하상 퇴적물 보다 큰 지를 확인함
			excessTransportCapacity ... % 유입량 제외 퇴적물 운반능력 [m^3/subDT]
				= transportCapacity(iCellY,iCellX) - inputFlux(iCellY,iCellX);
            if excessTransportCapacity <= chanBedSed(iCellY,iCellX)

				% (A) 퇴적물 운반능력이 하상 퇴적물보다 작다면 운반제어환경임
				outputFlux(iCellY,iCellX) = transportCapacity(iCellY,iCellX);
				dSedimentThick(iCellY,iCellX) ...
					= (inputFlux(iCellY,iCellX) - outputFlux(iCellY,iCellX)) ...
                        / CELL_AREA;
				dChanBedSed(iCellY,iCellX) ...
					= dSedimentThick(iCellY,iCellX) * CELL_AREA;
                    
                % for debug
                if sedimentThick(iCellY,iCellX) + dSedimentThick(iCellY,iCellX) < 0                
                    error('EstimateDElevByFluvialProcess_m:negativeSedimentThick','negative sediment thickness');                    
                end
                if outputFlux(iCellY,iCellX) < 0
                    error('EstimateDElevByFluvialProcess_m:negativeOutputFlux','negative output flux');                    
                end
                
            else

				% (B) 퇴적물 운반능력이 하상 퇴적물보다 크면 분리제어환경임
				% 다음 셀의 기반암 하상 고도를 고려하여 기반암 하식률을 산정하는 것을 추가함
				dBedrockElev(iCellY,iCellX) ...
					= - (bedrockIncision(iCellY,iCellX) / CELL_AREA);
				
                % prevent bedrock elevation from being lowered compared to
				% donwstream node
				tmpBedElev = bedrockElev(iCellY,iCellX) + dBedrockElev(iCellY,iCellX);
                if (tmpBedElev < bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                        && outputFluxRatioToE1(iCellY,iCellX) > 0) ...
                    || (tmpBedElev < bedrockElev(e2LinearIndicies(iCellY,iCellX)) ...
                        && outputFluxRatioToE2(iCellY,iCellX) > 0)
                    
                    if (bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                            > bedrockElev(e2LinearIndicies(iCellY,iCellX))) ...
                        && (outputFluxRatioToE1(iCellY,iCellX) > 0)
                    
                        dBedrockElev(iCellY,iCellX) ...
                            = bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                                - bedrockElev(iCellY,iCellX);
                            
                    else
                        
                        if outputFluxRatioToE2(iCellY,iCellX) > 0
                    
                            dBedrockElev(iCellY,iCellX) ...
                                = bedrockElev(e2LinearIndicies(iCellY,iCellX)) ...
                                    - bedrockElev(iCellY,iCellX);
                            
                        else
                            
                            dBedrockElev(iCellY,iCellX) ...
                                = bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                                    - bedrockElev(iCellY,iCellX);
                            
                        end                                
                    end
                    
                    if dBedrockElev(iCellY,iCellX) > 0
                        
                        % for the intitial condition in which upstream bedrock
                        % elevation is lower than its downstream (e1, e2)
                        if bedrockElev(iCellY,iCellX) < bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                            || bedrockElev(iCellY,iCellX) < bedrockElev(e2LinearIndicies(iCellY,iCellX))
                        
                            warning('EstimateDElevByFluvialProcess_m:negativeDBedrockElev' ...
                                ,'reversed dBedrockElev: diff with e1, %f; diff with e2, %f' ...
                                ,bedrockElev(e1LinearIndicies(iCellY,iCellX)) - bedrockElev(iCellY,iCellX) ...
                                ,bedrockElev(e2LinearIndicies(iCellY,iCellX)) - bedrockElev(iCellY,iCellX));
                            dBedrockElev(iCellY,iCellX) = 0;
                        
                        else
                            % for debug                            
                            error('EstimateDElevByFluvialProcess_m:negativeDBedrockElev','reversed dBedrockElev');
                            
                        end
                    end
                end

				outputFlux(iCellY,iCellX) ...
					= inputFlux(iCellY,iCellX) + chanBedSed(iCellY,iCellX) ...
                        - (dBedrockElev(iCellY,iCellX) * CELL_AREA);
				% don't include flux due to bedrock incision
				dSedimentThick(iCellY,iCellX) ...
					= - (inputFlux(iCellY,iCellX) + chanBedSed(iCellY,iCellX)) ...
                        / CELL_AREA;
                if sedimentThick(iCellY,iCellX) + dSedimentThick(iCellY,iCellX) < 0                
                    dSedimentThick(iCellY,iCellX) = - sedimentThick(iCellY,iCellX);
                    outputFlux(iCellY,iCellX) ...
                        = - (dSedimentThick(iCellY,iCellX) + dBedrockElev(iCellY,iCellX)) * CELL_AREA;
                end
				dChanBedSed(iCellY,iCellX) ...
					= dSedimentThick(iCellY,iCellX) * CELL_AREA;
                    
                % for debug
                if outputFlux(iCellY,iCellX) < 0
                    error('EstimateDElevByFluvialProcess_m:negativeOutputFlux','negative output flux');                    
                end
                
            end
        end % hillslope(iCellY,iCellX) == true

        % B. 무한유향을 따라 다음 셀(e1,e2)의 유입량에 유출량을 더함

        % A) 다음 셀에 운반될 퇴적물 [m^3/subDT]
        outputFluxToE1 = outputFluxRatioToE1(iCellY,iCellX) ...
                            * outputFlux(iCellY,iCellX);
        outputFluxToE2 = outputFluxRatioToE2(iCellY,iCellX) ...
                            * outputFlux(iCellY,iCellX);

        % B) 다음 셀이 flooded region인지를 확인함
        if flood(e1LinearIndicies(iCellY,iCellX)) ~= FLOODED
            % flooded region이 아니라면, 다음 셀에 직접 반영함
            inputFlux(e1LinearIndicies(iCellY,iCellX)) ...
                = inputFlux(e1LinearIndicies(iCellY,iCellX)) ...
                + outputFluxToE1;

        else
            % flooded region이라면 inputFloodedRegion에 유출량을 반영함
            outletY = SDSNbrY(e1LinearIndicies(iCellY,iCellX));
            outletX = SDSNbrX(e1LinearIndicies(iCellY,iCellX));

            inputFloodedRegion(outletY,outletX) ...
                = inputFloodedRegion(outletY,outletX) + outputFluxToE1;

        end

        if flood(e2LinearIndicies(iCellY,iCellX)) ~= FLOODED
            % flooded region이 아니라면, 다음 셀에 직접 반영함
            inputFlux(e2LinearIndicies(iCellY,iCellX)) ...
                = inputFlux(e2LinearIndicies(iCellY,iCellX)) ...
                + outputFluxToE2;

        else
            % flooded region이라면 inputFloodedRegion에 유출량을 반영함
            outletY = SDSNbrY(e2LinearIndicies(iCellY,iCellX));
            outletX = SDSNbrX(e2LinearIndicies(iCellY,iCellX));

            inputFloodedRegion(outletY,outletX) ...
                = inputFloodedRegion(outletY,outletX) + outputFluxToE2;
        end            
        
	else % floodedRegionCellsNo(iCellY,iCellX) ~= 0

        % i번째 셀이 유출구라면 무한유향을 이용하지 않고, 최대하부경사 유향알고리듬을 이용함.
        % 즉 SDSNbrY,SDSNbrX가 가리키는 다음 셀로 퇴적물을 전달함

        % (1) flooded region으로의 퇴적물 유입량이 flooded region의 저장량을 초과하는지
        % 확인하고 이를 i번째 셀의 유입률에 반영함
        if inputFloodedRegion(iCellY,iCellX) ...
            > floodedRegionStorageVolume(iCellY,iCellX)

            % A. 초과할 경우, 초과량을 유출구의 유입률에 더함
            inputFlux(iCellY,iCellX) = inputFlux(iCellY,iCellX) ...
                + (inputFloodedRegion(iCellY,iCellX) ...
                    - floodedRegionStorageVolume(iCellY,iCellX));

            % B. flooded region이 유입한 퇴적물로 채워졌다고 표시함
            isFilled(iCellY,iCellX) = true;

        end

        % (2) i번째 셀이 사면인지를 확인함
        if hillslope(iCellY,iCellX) == true

            % A. 사면이라면, 지표유출에 의한 침식률을 구함
            outputFlux(iCellY,iCellX) = transportCapacityForShallow(iCellY,iCellX);
            dSedimentThick(iCellY,iCellX) ...
                = (inputFlux(iCellY,iCellX) - outputFlux(iCellY,iCellX)) / CELL_AREA;

            % to do: 기반암 고도에는 영향을 주지 않는 것으로 처리함
            if sedimentThick(iCellY,iCellX) + dSedimentThick(iCellY,iCellX) < 0
                dSedimentThick(iCellY,iCellX) = -sedimentThick(iCellY,iCellX);
                outputFlux(iCellY,iCellX) = sedimentThick(iCellY,iCellX) * CELL_AREA;
            end

        else

            % B. 하천이라면, 하천작용에 의한 유출률을 구하고 이를 다음 셀에 분배함

            % A) 퇴적물 운반능력[m^3/subDT]이 하도 내 하상 퇴적물 보다 큰 지를 확인함
            excessTransportCapacity ... % 유입량 제외 퇴적물 운반능력 [m^3/subDT]
                = transportCapacity(iCellY,iCellX) - inputFlux(iCellY,iCellX);
            if excessTransportCapacity <= chanBedSed(iCellY,iCellX)

                % (A) 퇴적물 운반능력이 하상 퇴적물보다 작다면 운반제어환경임
                outputFlux(iCellY,iCellX) = transportCapacity(iCellY,iCellX);
                dSedimentThick(iCellY,iCellX) ...
                    = (inputFlux(iCellY,iCellX) - outputFlux(iCellY,iCellX)) ...
                        / CELL_AREA;
                dChanBedSed(iCellY,iCellX) ...
                    = dSedimentThick(iCellY,iCellX) * CELL_AREA;
                    
                % for debug
                if sedimentThick(iCellY,iCellX) + dSedimentThick(iCellY,iCellX) < 0                
                    error('EstimateDElevByFluvialProcess_m:negativeSedimentThick','negative sediment thickness');                    
                end
                if outputFlux(iCellY,iCellX) < 0
                    error('EstimateDElevByFluvialProcess_m:negativeOutputFlux','negative output flux');                    
                end

            else

                % (B) 퇴적물 운반능력이 하상 퇴적물보다 크면 분리제어환경임
                % 다음 셀의 기반암 하상 고도를 고려하여 기반암 하식률을 산정하는 것을 추가함
                dBedrockElev(iCellY,iCellX) ...
                    = - (bedrockIncision(iCellY,iCellX) / CELL_AREA);
				
                % prevent bedrock elevation from being lowered compared to
				% donwstream node
				tmpBedElev = bedrockElev(iCellY,iCellX) + dBedrockElev(iCellY,iCellX);
                if (tmpBedElev < bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                        && outputFluxRatioToE1(iCellY,iCellX) > 0) ...
                    || (tmpBedElev < bedrockElev(e2LinearIndicies(iCellY,iCellX)) ...
                        && outputFluxRatioToE2(iCellY,iCellX) > 0)
                    
                    if (bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                            > bedrockElev(e2LinearIndicies(iCellY,iCellX))) ...
                        && (outputFluxRatioToE1(iCellY,iCellX) > 0)
                    
                        dBedrockElev(iCellY,iCellX) ...
                            = bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                                - bedrockElev(iCellY,iCellX);
                            
                    else
                        
                        if outputFluxRatioToE2(iCellY,iCellX) > 0
                    
                            dBedrockElev(iCellY,iCellX) ...
                                = bedrockElev(e2LinearIndicies(iCellY,iCellX)) ...
                                    - bedrockElev(iCellY,iCellX);
                            
                        else
                            
                            dBedrockElev(iCellY,iCellX) ...
                                = bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                                    - bedrockElev(iCellY,iCellX);
                            
                        end                                
                    end
                        
                    if dBedrockElev(iCellY,iCellX) > 0
                        
                        % for the intitial condition in which upstream bedrock
                        % elevation is lower than its downstream (e1, e2)
                        if bedrockElev(iCellY,iCellX) < bedrockElev(e1LinearIndicies(iCellY,iCellX)) ...
                            || bedrockElev(iCellY,iCellX) < bedrockElev(e2LinearIndicies(iCellY,iCellX))
                        
                            warning('EstimateDElevByFluvialProcess_m:negativeDBedrockElev' ...
                                ,'reversed dBedrockElev: diff with e1, %f; diff with e2, %f' ...
                                ,bedrockElev(e1LinearIndicies(iCellY,iCellX)) - bedrockElev(iCellY,iCellX) ...
                                ,bedrockElev(e2LinearIndicies(iCellY,iCellX)) - bedrockElev(iCellY,iCellX));
                            dBedrockElev(iCellY,iCellX) = 0;
                        
                        else
                            % for debug                            
                            error('EstimateDElevByFluvialProcess_m:negativeDBedrockElev','reversed dBedrockElev');
                            
                        end
                    end
                end
                
                outputFlux(iCellY,iCellX) ...
                    = inputFlux(iCellY,iCellX) + chanBedSed(iCellY,iCellX) ...
                        - (dBedrockElev(iCellY,iCellX) * CELL_AREA);
                % don't include flux due to bedrock incision
                dSedimentThick(iCellY,iCellX) ...
                    = - (inputFlux(iCellY,iCellX) + chanBedSed(iCellY,iCellX)) ...
                        / CELL_AREA;
                if sedimentThick(iCellY,iCellX) + dSedimentThick(iCellY,iCellX) < 0                
                    dSedimentThick(iCellY,iCellX) = - sedimentThick(iCellY,iCellX);
                    outputFlux(iCellY,iCellX) ...
                        = - (dSedimentThick(iCellY,iCellX) + dBedrockElev(iCellY,iCellX)) * CELL_AREA;
                end
				dChanBedSed(iCellY,iCellX) ...
					= dSedimentThick(iCellY,iCellX) * CELL_AREA;
                    
                % for debug
                if outputFlux(iCellY,iCellX) < 0
                    error('EstimateDElevByFluvialProcess_m:negativeOutputFlux','negative output flux');                    
                end

            end
        end % hillslope(iCellY,iCellX) == true

        % B) 최대하부경사 유향을 따라 다음 셀의 유입률에 유출률을 더함

        % (A) 최대하부경사 유향이 가리키는 다음 셀 좌표
        nextY = SDSNbrY(iCellY,iCellX);
        nextX = SDSNbrX(iCellY,iCellX);

        % (B) 다음 셀이 flooded region인지를 확인함
        if flood(nextY,nextX) ~= FLOODED

            inputFlux(nextY,nextX) ...
                = inputFlux(nextY,nextX) + outputFlux(iCellY,iCellX);

        else

            outletY = SDSNbrY(nextY,nextX);
            outletX = SDSNbrX(nextY,nextX);                

            inputFloodedRegion(outletY,outletX) ...
                = inputFloodedRegion(outletY,outletX) + outputFlux(iCellY,iCellX);

        end % flood(nextY,nextX) ~= FLOODED
    end % floodedRegionCellsNo(iCellY,iCellX) == 0
end % for iCell = 1:considerCellsNo
