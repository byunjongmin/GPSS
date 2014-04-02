/*
 * EstimateDElevByFluvialProcess.c
 *
 * version 0.2
 *
 * flooded region�� ������ ������ �������, ��õ�� ���� ������ �β� ��
 * ��ݾ� �� ��ȭ���� ���ϴ� �Լ�. FluvialProcess �Լ�(ver 0.8)�� for
 * �ݺ������� C �� ������
 * 
 * [dSedimentThick ...          0 ������ �β� ��ȭ�� [m/subDT]
 * ,dBedrockElev ...            1 ��ݾ� ��ȭ�� [m/subDT]
 * ,dChanBedSed ...             2 �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT]
 * ,inputFlux ...               3 ��� �������� ������ ������ [m^3/subDT]
 * ,outputFlux...               4 �Ϸ����� ������ [m^3/subDT]
 * ,inputFloodedRegion ...      5 flooded region������ ������ [m^3/subDT]
 * ,isFilled ...                6 flooded region�� ���� ����
 * ] = EstimateDElevByFluvialProcess ...
 * (dX ...                      0 . �� ũ��
 * ,mRows ...                   1 . �� ����
 * ,nCols ...                   2 . �� ����
 * ,consideringCellsNo)         3 . ��õ�ۿ��� �߻��ϴ� �� ��
 *----------------------------- mexGetVariablePtr �Լ��� �����ϴ� ����
 * mexSortedIndicies ...        4 . �������� ���ĵ� ����
 * e1LinearIndicies ...         5 . ���� �� ����
 * e2LinearIndicies ...         6 . ���� �� ����
 * outputFluxRatioToE1 ...      7 . ���� ������ ���� ����
 * outputFluxRatioToE2 ...      8 . ���� ������ ���� ����
 * mexSDSNbrIndicies ...        9 . ���� �� ����
 * flood ...                    10 . flooded region
 * floodedRegionCellsNo ...     11 . flooded region ���� �� ��
 * floodedRegionStorageVolume . 12 . flooded region ���差
 * bankfullWidth ...            13 . ���������� ����
 * transportCapacity ...        14 . ������ ��ݴɷ�
 * bedrockIncision ...          15 . ��ݾ� �ϻ� ħ����
 * chanBedSed ...               16 . �ϵ� �� �ϻ� ������ �β�
 * sedimentThick ...            17 . ������ �β�
 * hillslope ...                18 . ��� ��
 * transportCapacityForShallow  19 . ��ǥ����� ���� �����̵�
 *------------------------------------------------------------------------- 
 *
 * ������ ��
 *
 * - 20101227
 *  - ��ǥ����� ���� �����̵��� ������
 * 
 */

# include "mex.h"

/* ��� �Լ� ���� */
void EstimateDElevByFluvialProcess(
    double * dSedimentThick,
    double * dBedrockElev,
    double * dChanBedSed,
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mxLogical * isFilled,
    int dX,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume,
    double * bankfullWidth,
    double * transportCapacity,
    double * bedrockIncision,
    double * chanBedSed,
    double * sedimentThick,
    double * hillslope,
    double * transportCapacityForShallow);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* �Է� ���� ����
     * ����: mxArray �ڷ��� ������ mexGetVariablePtr �Լ��� �̿��Ͽ�
     * ȣ���Լ��� �۾������� �ִ� �������� �����͸� �ҷ��� */
    /* ȣ���Լ� �۾������� ���� */
    const mxArray * mxArray4; /* mexSortedIndicies */
    const mxArray * mxArray5; /* e1LinearIndicies */
    const mxArray * mxArray6; /* e2LinearIndicies */
    const mxArray * mxArray7; /* outputFluxRatioToE1 */
    const mxArray * mxArray8; /* outputFluxRatioToE2 */
    const mxArray * mxArray9; /* mexSDSNbrIndicies */
    const mxArray * mxArray10; /* flood */
    const mxArray * mxArray11; /* floodedRegionCellsNo */
    const mxArray * mxArray12; /* floodedRegionStorageVolume */
    const mxArray * mxArray13; /* bankfullWidth */
    const mxArray * mxArray14; /* transportCapacity */
    const mxArray * mxArray15; /* bedrockIncision */
    const mxArray * mxArray16; /* chanBedSed */
    const mxArray * mxArray17; /* sedimentThick */
    const mxArray * mxArray18; /* hillslope */
    const mxArray * mxArray19; /* transportCapacityForShallow */
    
    /* �Էº��� ���� �ڷ�  */
    int dX;
    mwSize mRows;
    mwSize nCols;
    mwSize consideringCellsNo;
    double * mexSortedIndicies;
    double * e1LinearIndicies;
    double * e2LinearIndicies;
    double * outputFluxRatioToE1;
    double * outputFluxRatioToE2;
    double * mexSDSNbrIndicies;
    double * flood;
    double * floodedRegionCellsNo;
    double * floodedRegionStorageVolume;
    double * bankfullWidth;
    double * transportCapacity;
    double * bedrockIncision;
    double * chanBedSed;
    double * sedimentThick;
    double * hillslope;
    double * transportCapacityForShallow;
    
    /* ��� ���� ���� */
    double * dSedimentThick;
    double * dBedrockElev;
    double * dChanBedSed;
    double * inputFlux;
    double * outputFlux;
    double * inputFloodedRegion;
    mxLogical * isFilled;
    
    /* �Է� ���� �ʱ�ȭ */      
    dX                  = (int) mxGetScalar(prhs[0]);
    mRows               = (mwSize) mxGetScalar(prhs[1]);
    nCols               = (mwSize) mxGetScalar(prhs[2]);
    consideringCellsNo  = (mwSize) mxGetScalar(prhs[3]);
    
    mxArray4    = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray5    = mexGetVariablePtr("caller","e1LinearIndicies");    
    mxArray6    = mexGetVariablePtr("caller","e2LinearIndicies");    
    mxArray7    = mexGetVariablePtr("caller","outputFluxRatioToE1");
    mxArray8    = mexGetVariablePtr("caller","outputFluxRatioToE2");
    mxArray9    = mexGetVariablePtr("caller","mexSDSNbrIndicies");
    mxArray10   = mexGetVariablePtr("caller","flood");
    mxArray11   = mexGetVariablePtr("caller","floodedRegionCellsNo");
    mxArray12   = mexGetVariablePtr("caller","floodedRegionStorageVolume");
    mxArray13   = mexGetVariablePtr("caller","bankfullWidth");
    mxArray14   = mexGetVariablePtr("caller","transportCapacity");
    mxArray15   = mexGetVariablePtr("caller","bedrockIncision");
    mxArray16   = mexGetVariablePtr("caller","chanBedSed");
    mxArray17   = mexGetVariablePtr("caller","sedimentThick");
    mxArray18   = mexGetVariablePtr("caller","hillslope");
    mxArray19   = mexGetVariablePtr("caller","transportCapacityForShallow");
    
    mexSortedIndicies           = mxGetPr(mxArray4);    
    e1LinearIndicies            = mxGetPr(mxArray5);    
    e2LinearIndicies            = mxGetPr(mxArray6);    
    outputFluxRatioToE1         = mxGetPr(mxArray7);    
    outputFluxRatioToE2         = mxGetPr(mxArray8);    
    mexSDSNbrIndicies           = mxGetPr(mxArray9);    
    flood                       = mxGetPr(mxArray10);    
    floodedRegionCellsNo        = mxGetPr(mxArray11);    
    floodedRegionStorageVolume  = mxGetPr(mxArray12);    
    bankfullWidth               = mxGetPr(mxArray13);
    transportCapacity           = mxGetPr(mxArray14);    
    bedrockIncision             = mxGetPr(mxArray15);
    chanBedSed                  = mxGetPr(mxArray16);
    sedimentThick               = mxGetPr(mxArray17);
    hillslope                   = mxGetPr(mxArray18);
    transportCapacityForShallow = mxGetPr(mxArray19);
    
    /* ��� ���� �ʱ�ȭ */
    plhs[0] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[3] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[4] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[5] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[6] = mxCreateLogicalMatrix(mRows,nCols);
    
    /* ��� ���� �ڷῡ �����͸� ���� */
    dSedimentThick = mxGetPr(plhs[0]);
    dBedrockElev = mxGetPr(plhs[1]);
    dChanBedSed = mxGetPr(plhs[2]);
    inputFlux = mxGetPr(plhs[3]);
    outputFlux = mxGetPr(plhs[4]);
    inputFloodedRegion = mxGetPr(plhs[5]);
    isFilled = mxGetLogicals(plhs[6]);
    
    /* ���� ��ƾ ���� */
    EstimateDElevByFluvialProcess(
        dSedimentThick,
        dBedrockElev,
        dChanBedSed,
        inputFlux,
        outputFlux,
        inputFloodedRegion,
        isFilled,
        dX,
        consideringCellsNo,
        mexSortedIndicies,
        e1LinearIndicies,
        e2LinearIndicies,
        outputFluxRatioToE1,
        outputFluxRatioToE2,
        mexSDSNbrIndicies,
        flood,
        floodedRegionCellsNo,
        floodedRegionStorageVolume,
        bankfullWidth,
        transportCapacity,
        bedrockIncision,
        chanBedSed,
        sedimentThick,
        hillslope,
        transportCapacityForShallow);

}

void EstimateDElevByFluvialProcess(
    double * dSedimentThick,
    double * dBedrockElev,
    double * dChanBedSed,
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mxLogical * isFilled,
    int dX,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume,
    double * bankfullWidth,
    double * transportCapacity,
    double * bedrockIncision,
    double * chanBedSed,
    double * sedimentThick,
    double * hillslope,
    double * transportCapacityForShallow)
{
    /* �ӽ� ���� ���� */
    mwIndex ithCell,ithCellIdx,outlet,next,e1,e2;
    double excessTransportCapacity,outputFluxToE1,outputFluxToE2;
    
    const int FLOODED = 2; /* flooded region */
    const int TRUE = 1;
    const int CELL_AREA = dX * dX;
            
    /* (���� �� ������) ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ� �� ��ȭ���� ���� */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {        
        /* 1. i��° ���� ����
         * *  ����: MATLAB �迭 ���� ������ ���� '-1'�� ������ */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;

        /* 2. i���� ���� �������� ���ϰ�, �̸� ������ ���� ���� ���� �й��� */

        /* 1). i��° ���� flooded region�� ���ⱸ������ Ȯ���� */
        if ((int) floodedRegionCellsNo[ithCellIdx] == 0)
        {
            
            /* (1) i��° ���� ��������� Ȯ���� */
            if ((int) hillslope[ithCellIdx] == TRUE)                
            {
            
                outputFlux[ithCellIdx] = transportCapacityForShallow[ithCellIdx];
                
                dSedimentThick[ithCellIdx] 
                        = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                
                if ((sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx]) < 0)
                {
                        
                    dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                        
                    outputFlux[ithCellIdx] = sedimentThick[ithCellIdx];                    
                }
            
            }
            
            else
            {
                
                /* A. flooded region�� ���ⱸ�� �ƴ϶�� ��õ�ۿ뿡 ���� ��������
                 *     ���ϰ� �̸� ���� ������ ���� ���� ���� �й��� */

                /* A) �ʰ� ������ ��ݴɷ�[m^3/subDT]�� �ϵ� �� �ϻ� ���������� ū ���� Ȯ���� */
                excessTransportCapacity /* [m^3/subDT] */
                    = transportCapacity[ithCellIdx] - inputFlux[ithCellIdx];

                if (excessTransportCapacity > chanBedSed[ithCellIdx])
                {
                    /* (A) �ʰ� ������ ��ݴɷ��� �ϻ� ���������� ũ�� �и�����ȯ���� */

                    /* a. ���� ������ ������([m^3/subDT])�� ���� */
                    outputFlux[ithCellIdx] = inputFlux[ithCellIdx] 
                        + chanBedSed[ithCellIdx] + bedrockIncision[ithCellIdx];

                    /* b. �и�����ȯ�� �Ʒ� �������� ������ ��ݴɷº��ٴ� ���� */
                    if (outputFlux[ithCellIdx] > transportCapacity[ithCellIdx])
                    {
                       outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];
                    }

                    /* c. ������ �β� ��ȭ�� [m/subDT] */
                    dSedimentThick[ithCellIdx] = - chanBedSed[ithCellIdx]
                        / CELL_AREA;

                    /* d. ��ݾ� �ϻ� ħ���� [m/subDT] */
                    /* ����: outputFlux�� �����Ǿ��� �� �ֱ� ������, �Ʒ� ������
                     * ������� ���� */
                    /* dBedrockElev[ithCellIdx] = - bedrockIncision[ithCellIdx]; */
                    dBedrockElev[ithCellIdx] = - (outputFlux[ithCellIdx]
                        - (chanBedSed[ithCellIdx] + inputFlux[ithCellIdx]))
                        / CELL_AREA;

                    /* e. �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT] */
                    dChanBedSed[ithCellIdx] = - chanBedSed[ithCellIdx];
                }
                else
                {
                    /* (B) ������ ��ݴɷ��� �ϻ� ���������� �۴ٸ�, �������ȯ���� */

                    /* a. ���� ������ ������ [m^3/subDT] */
                    outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];

                    /* b. ������ �β� ��ȭ�� [m/subDT] */
                    dSedimentThick[ithCellIdx] = (inputFlux[ithCellIdx]
                        - outputFlux[ithCellIdx]) / CELL_AREA;

                    /* c. �ϵ� �� �ϻ� ������ ���� [m^3] */
                    dChanBedSed[ithCellIdx] = inputFlux[ithCellIdx] 
                            - outputFlux[ithCellIdx];
                }
            }

            /* B. ���� ������ ���� ���� ��(e1,e2)�� �������� �������� ���� */
            
            /* ���� �� ����
             * *  ����: MATLAB �迭 ���� ������ ���� '-1'�� ������ */
            e1 = (mwIndex) e1LinearIndicies[ithCellIdx] - 1;
            e2 = (mwIndex) e2LinearIndicies[ithCellIdx] - 1;
            
            /* A) ���� ���� ��ݵ� ������ ������ [m^3/subDT]*/
            outputFluxToE1 = outputFluxRatioToE1[ithCellIdx] 
                * outputFlux[ithCellIdx];
            outputFluxToE2 = outputFluxRatioToE2[ithCellIdx]
                * outputFlux[ithCellIdx];

            /* B) ���� ���� flooded region�̶�� inputFloodedRegion��
             *    �������� �ݿ��ϰ� �׷��� �ʴٸ� ���� ���� ���� �ݿ��� */
            if ((int) flood[e1] == FLOODED)
            {
                /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                outlet = (mwIndex) mexSDSNbrIndicies[e1] - 1;                

                inputFloodedRegion[outlet] /* [m^3/subDT] */
                    = inputFloodedRegion[outlet] + outputFluxToE1;
            }
            else /* flood[e1] ~= FLOODED */
            {
                inputFlux[e1] = inputFlux[e1] + outputFluxToE1;
            }
            
            if ((int) flood[e2] == FLOODED)
            {
                /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                outlet = (mwIndex) mexSDSNbrIndicies[e2] - 1;                

                inputFloodedRegion[outlet] /* [m^3/subDT] */
                    = inputFloodedRegion[outlet] + outputFluxToE2;
            }
            else
            {
                inputFlux[e2] = inputFlux[e2] + outputFluxToE2;
            }
        }
        else /* (floodedRegionCellsNo[ithCellIdx] != 0) */
        {
            /* (2) i��° ���� flooded region�� ���ⱸ��� ���� ������
             *     �̿����� �ʰ�, �ִ��Ϻΰ�� ���� �˰����� �̿��Ѵ�.��,
             *     SDSNbrY,SDSNbrX�� ����Ű�� ���� ���� �������� ������ */

            /* A. flooded region������ ������ ���Է��� flooded region��
             *    ���差�� �ʰ��ϴ��� Ȯ���� */
            if (inputFloodedRegion[ithCellIdx] 
                    > floodedRegionStorageVolume[ithCellIdx])
            {
                /* A) �ʰ��� ���, �ʰ����� ���ⱸ�� �������� ���� */
                inputFlux[ithCellIdx] = inputFlux[ithCellIdx]
                    + (inputFloodedRegion[ithCellIdx]
                    - floodedRegionStorageVolume[ithCellIdx]);

                /* B) flooded region�� ������ �������� ä�����ٰ� ǥ���� */
                isFilled[ithCellIdx] = TRUE;
            }
            
            
            /* B. i��° ���� ��������� Ȯ���� */
            if ((int) hillslope[ithCellIdx] == TRUE)                
            {
            
                outputFlux[ithCellIdx] = transportCapacityForShallow[ithCellIdx];
                
                dSedimentThick[ithCellIdx] 
                        = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                
                if ((sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx]) < 0)
                {
                        
                    dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                        
                    outputFlux[ithCellIdx] = sedimentThick[ithCellIdx];                    
                }
            
            }
            
            else
            {
                        
                /* A) �ʰ� ������ ��ݴɷ��� �ϻ� ���������� ū ���� Ȯ���� */
                excessTransportCapacity /* [m^3/subDT] */
                    = transportCapacity[ithCellIdx] - inputFlux[ithCellIdx];

                if (excessTransportCapacity > chanBedSed[ithCellIdx])
                {
                    /* (A) �ʰ� ������ ��ݴɷ��� �ϻ� ������������ ũ�� �и�����ȯ���� */

                    /* a. ���� ������ ������ [m^3/subDT] */
                    outputFlux[ithCellIdx] = inputFlux[ithCellIdx]
                        + chanBedSed[ithCellIdx] + bedrockIncision[ithCellIdx];

                    /* b. �и�����ȯ�� �Ʒ� �������� ������ ��ݴɷº��ٴ� ���� */
                    if (outputFlux[ithCellIdx] > transportCapacity[ithCellIdx])
                    {
                       outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];
                    }

                    /* c. ������ �β� ��ȭ�� [m/subDT] */
                    dSedimentThick[ithCellIdx] = - chanBedSed[ithCellIdx]
                        / CELL_AREA;

                    /* d. ��ݾ� �ϻ� �� ��ȭ�� [m/subDT] */
                    /* ����: outputFlux�� �����Ǿ��� �� �ֱ� ������, �Ʒ� ������
                     * ������� ���� */
                    /* dBedrockElev[ithCellIdx] = - bedrockIncision[ithCellIdx]; */
                    dBedrockElev[ithCellIdx] = - (outputFlux[ithCellIdx]
                        - (chanBedSed[ithCellIdx] + inputFlux[ithCellIdx]))
                        / CELL_AREA;

                    /* e. �ϵ� �� �ϻ� ������ ��ȭ�� [m^3] */
                    dChanBedSed[ithCellIdx] = - chanBedSed[ithCellIdx];

                }
                else
                {
                    /* (B) ������ ��ݴɷ��� �ϻ� ���������� �۴ٸ�, �������ȯ���� */

                    /* a. ���� ������ ������ */
                    outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];

                    /* b. ������ �β� ��ȭ�� [m/subDT] */
                    dSedimentThick[ithCellIdx] = (inputFlux[ithCellIdx]
                        - outputFlux[ithCellIdx]) / CELL_AREA;

                    /* c. �ϵ� �� �ϻ� ������ ��ȭ�� [m^3] */
                    dChanBedSed[ithCellIdx] = inputFlux[ithCellIdx] 
                            - outputFlux[ithCellIdx];

                }
            }
            
            /* C. �ִ��Ϻΰ�� ������ ���� ���� ���� �������� �������� ���� */
            /* A) �ִ� �Ϻ� ��� ������ ����Ű�� ���� ���� ��ǥ
            * *  ����: MATLAB �迭 ���� ������ ���� '-1'�� ������ */
            next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;            

            /* B) ���� ���� flooded region �̶�� inputFloodedRegion��
             *    �������� �ݿ��ϰ� �׷��� �ʴٸ� ���� ���� ���� �ݿ��� */
            if  ( flood[next] == FLOODED )
            {
                /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                outlet = (mwIndex) mexSDSNbrIndicies[next];                                

                inputFloodedRegion[outlet] /* [m^3/subDT] */
                    = inputFloodedRegion[outlet] + outputFlux[ithCellIdx];
            }
            else
            {
               inputFlux[next] = inputFlux[next] + outputFlux[ithCellIdx];
            }        
        } /* (floodedRegionCellsNo[ithCellIdx] == 0) */
    } /* for ithCell=1:consideringCellsNo */        
} /* void ForFluvialProcess */