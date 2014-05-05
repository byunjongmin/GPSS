function ...
[dSedimentThick ...      % ������ �β� ��ȭ�� [m^3/m^2 subDT]
,dBedrockElev ...        % ��ݾ� �� ��ȭ�� [m^3/m^2 subDT]
,dChanBedSed ...         % �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT]
,inputFlux ...           % ��� �������� ������ ������ [m^3/subDT]
,outputFlux...           % �Ϸ����� ������ [m^3/subDT]
,inputFloodedRegion ...  % flooded region������ ������ [m^3/subDT]
,isFilled] ...           % ��� �������� ���� flooded region�� ���� ����
= EstimateDElevByFluvialProcess_m ...
(dX ...                         % �� ũ��
,mRows ...
,nCols ...
,consideringCellsNo ...         % ��õ�ۿ��� �߻��ϴ� �� ��
,sortedYXElev ... 		        % �������� ���ĵ� Y,X ��ǥ
,e1LinearIndicies ...           % ���� �� ����
,e2LinearIndicies ...           % ���� �� ����
,outputFluxRatioToE1 ...        % ���� ������ ���� ����
,outputFluxRatioToE2 ...        % ���� ������ ���� ����
,SDSNbrY ...                    % ���� �� ����
,SDSNbrX ...                    % ���� �� ����
,flood ...                      % flooded region
,floodedRegionCellsNo ...       % flooded region ���� �� ��
,floodedRegionStorageVolume ... % flooded region ���差
,transportCapacity ...          % �ִ� ������ ��ݴɷ�
,bedrockIncision ...			% ��ݾ� �ϻ� ħ����
,chanBedSed ...                 % �ϵ��� �ϻ� ������ ����
,bedrockElev ...				% ��ݾ� ��
,sedimentThick ...              % ������ �β�
,hillslope ...                  % ��� ��
,transportCapacityForShallow ...% ��ǥ����� ���� �����̵�
,elev) %#codegen

% define constants
FLOODED = 2;
CELL_AREA = dX * dX;

% define output variables
dSedimentThick = zeros(mRows,nCols);    % ������ �β� ��ȭ�� [m^3/m^2 subDT]
dBedrockElev = zeros(mRows,nCols);  % ��ݾ� �� ��ȭ�� [m^3/m^2 subDT]
dChanBedSed = zeros(mRows,nCols);   % ��ݾ� �� ��ȭ�� [m^3/m^2 subDT]
inputFlux = zeros(mRows,nCols);     % ��� �������κ����� ���Է� [m^3/subDT]
outputFlux = zeros(mRows,nCols);    % ������ ���� ���� ������ ���ⷮ [m^3/subDT]
inputFloodedRegion = zeros(mRows,nCols); % flooded region������ ���Է�[m^3/subDT]
isFilled = false(mRows,nCols);      % flooded region������ ���Է��� ���差�� �ʰ��ߴ��� ǥ���ϴ� �±�

% (���� �� ������) ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ� �� ��ȭ���� ����
for iCell = 1:consideringCellsNo

	% 1. i��° �� ����
	iCellY = sortedYXElev(iCell,1);
	iCellX = sortedYXElev(iCell,2);

	% 2. i��° ���� ������� ���ϰ� �̸� ������ ���� ���� ���� �й���

	% 1) i��° ���� flooded region ���ⱸ������ Ȯ����	
	if floodedRegionCellsNo(iCellY,iCellX) == 0
    
		% ���ⱸ�� �ƴ϶�� (�Ϲ�����), ��ǥ���� �� ��õ�� ���� ���ⷮ��
		%  ���ϰ� �̸� ���� ������ ���� ���� ���� �й���
		
		% (1) i��° ���� ��������� Ȯ����
        if hillslope(iCellY,iCellX) == true

			% A. ����̶��, ��ǥ���⿡ ���� ħ�ķ��� ����
			outputFlux(iCellY,iCellX) = transportCapacityForShallow(iCellY,iCellX);
			dSedimentThick(iCellY,iCellX) ...
				= (inputFlux(iCellY,iCellX) - outputFlux(iCellY,iCellX)) / CELL_AREA;

			% to do: ��ݾ� ������ ������ ���� �ʴ� ������ ó����
			if sedimentThick(iCellY,iCellX) + dSedimentThick(iCellY,iCellX) < 0
				dSedimentThick(iCellY,iCellX) = -sedimentThick(iCellY,iCellX);
                outputFlux(iCellY,iCellX) = sedimentThick(iCellY,iCellX) * CELL_AREA;
			end

		else
			
			% B. ��õ�̶��, ��õ�ۿ뿡 ���� ������� ���ϰ� �̸� ���� ���� �й���
            
			% A) ������ ��ݴɷ�[m^3/subDT]�� �ϵ� �� �ϻ� ������ ���� ū ���� Ȯ����
			excessTransportCapacity ... % ���Է� ���� ������ ��ݴɷ� [m^3/subDT]
				= transportCapacity(iCellY,iCellX) - inputFlux(iCellY,iCellX);
            if excessTransportCapacity <= chanBedSed(iCellY,iCellX)

				% (A) ������ ��ݴɷ��� �ϻ� ���������� �۴ٸ� �������ȯ����
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

				% (B) ������ ��ݴɷ��� �ϻ� ���������� ũ�� �и�����ȯ����
				% ���� ���� ��ݾ� �ϻ� ���� ����Ͽ� ��ݾ� �Ͻķ��� �����ϴ� ���� �߰���
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

        % B. ���������� ���� ���� ��(e1,e2)�� ���Է��� ���ⷮ�� ����

        % A) ���� ���� ��ݵ� ������ [m^3/subDT]
        outputFluxToE1 = outputFluxRatioToE1(iCellY,iCellX) ...
                            * outputFlux(iCellY,iCellX);
        outputFluxToE2 = outputFluxRatioToE2(iCellY,iCellX) ...
                            * outputFlux(iCellY,iCellX);

        % B) ���� ���� flooded region������ Ȯ����
        if flood(e1LinearIndicies(iCellY,iCellX)) ~= FLOODED
            % flooded region�� �ƴ϶��, ���� ���� ���� �ݿ���
            inputFlux(e1LinearIndicies(iCellY,iCellX)) ...
                = inputFlux(e1LinearIndicies(iCellY,iCellX)) ...
                + outputFluxToE1;

        else
            % flooded region�̶�� inputFloodedRegion�� ���ⷮ�� �ݿ���
            outletY = SDSNbrY(e1LinearIndicies(iCellY,iCellX));
            outletX = SDSNbrX(e1LinearIndicies(iCellY,iCellX));

            inputFloodedRegion(outletY,outletX) ...
                = inputFloodedRegion(outletY,outletX) + outputFluxToE1;

        end

        if flood(e2LinearIndicies(iCellY,iCellX)) ~= FLOODED
            % flooded region�� �ƴ϶��, ���� ���� ���� �ݿ���
            inputFlux(e2LinearIndicies(iCellY,iCellX)) ...
                = inputFlux(e2LinearIndicies(iCellY,iCellX)) ...
                + outputFluxToE2;

        else
            % flooded region�̶�� inputFloodedRegion�� ���ⷮ�� �ݿ���
            outletY = SDSNbrY(e2LinearIndicies(iCellY,iCellX));
            outletX = SDSNbrX(e2LinearIndicies(iCellY,iCellX));

            inputFloodedRegion(outletY,outletX) ...
                = inputFloodedRegion(outletY,outletX) + outputFluxToE2;
        end            
        
	else % floodedRegionCellsNo(iCellY,iCellX) ~= 0

        % i��° ���� ���ⱸ��� ���������� �̿����� �ʰ�, �ִ��Ϻΰ�� ����˰����� �̿���.
        % �� SDSNbrY,SDSNbrX�� ����Ű�� ���� ���� �������� ������

        % (1) flooded region������ ������ ���Է��� flooded region�� ���差�� �ʰ��ϴ���
        % Ȯ���ϰ� �̸� i��° ���� ���Է��� �ݿ���
        if inputFloodedRegion(iCellY,iCellX) ...
            > floodedRegionStorageVolume(iCellY,iCellX)

            % A. �ʰ��� ���, �ʰ����� ���ⱸ�� ���Է��� ����
            inputFlux(iCellY,iCellX) = inputFlux(iCellY,iCellX) ...
                + (inputFloodedRegion(iCellY,iCellX) ...
                    - floodedRegionStorageVolume(iCellY,iCellX));

            % B. flooded region�� ������ �������� ä�����ٰ� ǥ����
            isFilled(iCellY,iCellX) = true;

        end

        % (2) i��° ���� ��������� Ȯ����
        if hillslope(iCellY,iCellX) == true

            % A. ����̶��, ��ǥ���⿡ ���� ħ�ķ��� ����
            outputFlux(iCellY,iCellX) = transportCapacityForShallow(iCellY,iCellX);
            dSedimentThick(iCellY,iCellX) ...
                = (inputFlux(iCellY,iCellX) - outputFlux(iCellY,iCellX)) / CELL_AREA;

            % to do: ��ݾ� ������ ������ ���� �ʴ� ������ ó����
            if sedimentThick(iCellY,iCellX) + dSedimentThick(iCellY,iCellX) < 0
                dSedimentThick(iCellY,iCellX) = -sedimentThick(iCellY,iCellX);
                outputFlux(iCellY,iCellX) = sedimentThick(iCellY,iCellX) * CELL_AREA;
            end

        else

            % B. ��õ�̶��, ��õ�ۿ뿡 ���� ������� ���ϰ� �̸� ���� ���� �й���

            % A) ������ ��ݴɷ�[m^3/subDT]�� �ϵ� �� �ϻ� ������ ���� ū ���� Ȯ����
            excessTransportCapacity ... % ���Է� ���� ������ ��ݴɷ� [m^3/subDT]
                = transportCapacity(iCellY,iCellX) - inputFlux(iCellY,iCellX);
            if excessTransportCapacity <= chanBedSed(iCellY,iCellX)

                % (A) ������ ��ݴɷ��� �ϻ� ���������� �۴ٸ� �������ȯ����
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

                % (B) ������ ��ݴɷ��� �ϻ� ���������� ũ�� �и�����ȯ����
                % ���� ���� ��ݾ� �ϻ� ���� ����Ͽ� ��ݾ� �Ͻķ��� �����ϴ� ���� �߰���
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

        % B) �ִ��Ϻΰ�� ������ ���� ���� ���� ���Է��� ������� ����

        % (A) �ִ��Ϻΰ�� ������ ����Ű�� ���� �� ��ǥ
        nextY = SDSNbrY(iCellY,iCellX);
        nextX = SDSNbrX(iCellY,iCellX);

        % (B) ���� ���� flooded region������ Ȯ����
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
