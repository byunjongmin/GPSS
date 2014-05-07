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
 * bedrockElev                  20 . ��ݾ� ��
 *------------------------------------------------------------------------- 
 *
 * ������ ��
 * - 20140430
 *  - dBedrockElev ���� ���� �߰���
 * - 20101227
 *  - ��ǥ����� ���� �����̵��� ������
 * 
 */

# include "mex.h"
# include "matrix.h"

/* Computational routine */
void EstimateDElevByFluvialProcess(
    double * dSedimentThick,                /* output 0 */
    double * dBedrockElev,                  /* output 1 */
    double * dChanBedSed,                   /* output 2 */
    double * inputFlux,                     /* output 3 */
    double * outputFlux,                    /* output 4 */
    double * inputFloodedRegion,            /* output 5 */
    mxLogical * isFilled,                   /* output 6 */
    double dX,                              /* input 0 */
    double consideringCellsNo,              /* input 3 */
    double * mexSortedIndicies,             /* input 4 */
    double * e1LinearIndicies,              /* input 5 */
    double * e2LinearIndicies,              /* input 6 */
    double * outputFluxRatioToE1,           /* input 7 */
    double * outputFluxRatioToE2,           /* input 8 */
    double * mexSDSNbrIndicies,             /* input 9 */
    double * flood,                         /* input 10 */
    double * floodedRegionCellsNo,          /* input 11 */
    double * floodedRegionStorageVolume,    /* input 12 */
    double * bankfullWidth,                 /* input 13 */
    double * transportCapacity,             /* input 14 */
    double * bedrockIncision,               /* input 15 */
    double * chanBedSed,                    /* input 16 */
    double * sedimentThick,                 /* input 17 */
    mxLogical * hillslope,                  /* input 18 */
    double * transportCapacityForShallow,   /* input 19 */
    double * bedrockElev);                  /* input 20 */

/* gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* check for proper number of arguments */
    /* validate the input values */
    
    /* variable declaration */
    
    /* input variable */
    double dX;
    double mRows;
    double nCols;
    double consideringCellsNo;
    /* ����: mxArray �ڷ��� ������ mexGetVariablePtr �Լ��� �̿��Ͽ�
     * ȣ���Լ��� �۾������� �ִ� �������� �����͸� �ҷ��� */
    const mxArray * mxArray4;
    const mxArray * mxArray5;
    const mxArray * mxArray6;
    const mxArray * mxArray7;
    const mxArray * mxArray8;
    const mxArray * mxArray9;
    const mxArray * mxArray10;
    const mxArray * mxArray11;
    const mxArray * mxArray12;
    const mxArray * mxArray13;
    const mxArray * mxArray14;
    const mxArray * mxArray15;
    const mxArray * mxArray16;
    const mxArray * mxArray17;
    const mxArray * mxArray18;
    const mxArray * mxArray19;
    const mxArray * mxArray20;
    
    mxArray4  = mexGetVariablePtr("caller","mexSortedIndicies");
    mxArray5  = mexGetVariablePtr("caller","e1LinearIndicies");
    mxArray6  = mexGetVariablePtr("caller","e2LinearIndicies");
    mxArray7  = mexGetVariablePtr("caller","outputFluxRatioToE1");
    mxArray8  = mexGetVariablePtr("caller","outputFluxRatioToE2");
    mxArray9  = mexGetVariablePtr("caller","mexSDSNbrIndicies");
    mxArray10 = mexGetVariablePtr("caller","flood");
    mxArray11 = mexGetVariablePtr("caller","floodedRegionCellsNo");
    mxArray12 = mexGetVariablePtr("caller","floodedRegionStorageVolume");
    mxArray13 = mexGetVariablePtr("caller","bankfullWidth");
    mxArray14 = mexGetVariablePtr("caller","transportCapacity");
    mxArray15 = mexGetVariablePtr("caller","bedrockIncision");
    mxArray16 = mexGetVariablePtr("caller","chanBedSed");
    mxArray17 = mexGetVariablePtr("caller","sedimentThick");
    mxArray18 = mexGetVariablePtr("caller","hillslope");
    mxArray19 = mexGetVariablePtr("caller","transportCapacityForShallow");
    mxArray20 = mexGetVariablePtr("caller","bedrockElev");
    
    /* output variable */
    double * dSedimentThick;
    double * dBedrockElev;
    double * dChanBedSed;
    double * inputFlux;
    double * outputFlux;
    double * inputFloodedRegion;
    mxLogical * isFilled;
    
    /* create a pointer to the real data in the input matrix */
    dX                  = mxGetScalar(prhs[0]);
    mRows               = mxGetScalar(prhs[1]);
    nCols               = mxGetScalar(prhs[2]);
    consideringCellsNo  = mxGetScalar(prhs[3]);
    
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
    mxLogical * hillslope;
    double * transportCapacityForShallow;
    double * bedrockElev;
    
    mexSortedIndicies              = mxGetPr(mxArray4);
    e1LinearIndicies               = mxGetPr(mxArray5);    
    e2LinearIndicies               = mxGetPr(mxArray6);    
    outputFluxRatioToE1            = mxGetPr(mxArray7);    
    outputFluxRatioToE2            = mxGetPr(mxArray8);    
    mexSDSNbrIndicies              = mxGetPr(mxArray9);    
    flood                          = mxGetPr(mxArray10);    
    floodedRegionCellsNo           = mxGetPr(mxArray11);    
    floodedRegionStorageVolume     = mxGetPr(mxArray12);    
    bankfullWidth                  = mxGetPr(mxArray13);
    transportCapacity              = mxGetPr(mxArray14);    
    bedrockIncision                = mxGetPr(mxArray15);
    chanBedSed                     = mxGetPr(mxArray16);
    sedimentThick                  = mxGetPr(mxArray17);
    hillslope                      = mxGetLogicals(mxArray18);
    transportCapacityForShallow    = mxGetPr(mxArray19);
    bedrockElev                    = mxGetPr(mxArray20);

    /* prepare output data */
    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[3] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[4] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[5] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[6] = mxCreateLogicalMatrix(mRows,nCols);
    
    /* get a pointer to the real data in the output matrix */
    dSedimentThick      = mxGetPr(plhs[0]);
    dBedrockElev        = mxGetPr(plhs[1]);
    dChanBedSed         = mxGetPr(plhs[2]);
    inputFlux           = mxGetPr(plhs[3]);
    outputFlux          = mxGetPr(plhs[4]);
    inputFloodedRegion  = mxGetPr(plhs[5]);
    isFilled            = mxGetLogicals(plhs[6]);
    
    /* call the computational routine */
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
        transportCapacityForShallow,
        bedrockElev);

}

void EstimateDElevByFluvialProcess(
    double * dSedimentThick,
    double * dBedrockElev,
    double * dChanBedSed,
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mxLogical * isFilled,
    double dX,
    double consideringCellsNo,
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
    mxLogical * hillslope,
    double * transportCapacityForShallow,
    double * bedrockElev)
{
    /* �ӽ� ���� ���� */
    mwIndex ithCell,ithCellIdx,outlet,next,e1,e2;
    double excessTransportCapacity,outputFluxToE1,outputFluxToE2;
    double tmpBedElev;
    
    const double FLOODED = 2; /* flooded region */
    const double CELL_AREA = dX * dX;
            
    /* (���� �� ������) ��õ�ۿ뿡 ���� ������ �β� �� ��ݾ� �� ��ȭ���� ���� */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {        
        /* 1. i��° �� �� ���� ���� ����
         * *  ����: MATLAB �迭 ���� ������ ���� '-1'�� ������ */
        ithCellIdx = (mwIndex)mexSortedIndicies[ithCell] - 1;
        e1 = (mwIndex)e1LinearIndicies[ithCellIdx] - 1;
        e2 = (mwIndex)e2LinearIndicies[ithCellIdx] - 1;

        /* 2. i���� ���� �������� ���ϰ�, �̸� ������ ���� ���� ���� �й��� */

        /* 1). i��° ���� flooded region�� ���ⱸ������ Ȯ���� */
        if ((mwSize)floodedRegionCellsNo[ithCellIdx] == 0)
        {
            /* ���ⱸ�� �ƴ϶��(�Ϲ�����), ��ǥ���� �� ��õ�� ���� ���ⷮ�� ���ϰ�
             * �̸� ���������� ���� ���� ���� �й��� */
            
            /* (1) i��° ���� ��������� Ȯ���� */
            if (hillslope[ithCellIdx] == true)                
            {
                /* A. ����̶��, ��ǥ���⿡ ���� ħ�ķ��� ����*/
                outputFlux[ithCellIdx] = transportCapacityForShallow[ithCellIdx];
                dSedimentThick[ithCellIdx] 
                        = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                
                /* to do: ��ݾ� ������ ������ ���� �ʴ� ������ ó����*/
                if ((sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx]) < 0)
                {     
                    dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                    outputFlux[ithCellIdx] = sedimentThick[ithCellIdx] * CELL_AREA;                    
                }            
            }
            else
            {
                /* B. ��õ�̶��, ��õ�� ���� ������� ���ϰ� �̸� ���� ���� �й��� */
                
                /* A) ������ ��ݴɷ��� �ϵ� �� �ϻ� ���������� ū ���� Ȯ���� */
                excessTransportCapacity /* ���Է� ���� ������ ��ݴɷ� [m^3/subDT] */
                    = transportCapacity[ithCellIdx] - inputFlux[ithCellIdx];
                if (excessTransportCapacity <= chanBedSed[ithCellIdx])
                {
                    /* (A) ������ ��ݴɷ��� �ϻ� ���������� �۴ٸ�, �������ȯ���� */
                    /* a. ���� ������ ������ [m^3/subDT] */
                    outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];
                    /* b. ������ �β� ��ȭ�� [m/subDT] */
                    dSedimentThick[ithCellIdx] 
                            = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                    /* c. �ϵ� �� �ϻ� ������ ���� [m^3] */
                    dChanBedSed[ithCellIdx] = dSedimentThick[ithCellIdx] * CELL_AREA;
                    
                    /* for debug */
                    if (sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx] < 0)
                    {
                        mexErrMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeSedimentThick","negative sediment thickness");
                    }
                    if (outputFlux[ithCellIdx] < 0)
                    {
                        mexErrMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeOutputFlux","negative output flux");
                    }
                }
                else /* (excessTransportCapacity > chanBedSed[ithCellIdx) */
                {
                    /* (B) ������ ��ݴɷ��� �ϻ� ���������� ũ�� �и�����ȯ���� */
                    /* ��ݾ� �Ͻķ� [m/subDT] */
                    /* * ����: ���� ���� ��ݾ� �ϻ� ���� ����Ͽ� ��ݾ� �Ͻķ��� �����ϴ� ���� �߰��� */
                    dBedrockElev[ithCellIdx] = - (bedrockIncision[ithCellIdx] / CELL_AREA);
                   
                    /* prevent bedrock elevation from being lowered compared to downstream node */
                    tmpBedElev = bedrockElev[ithCellIdx] + dBedrockElev[ithCellIdx];
                    if (((tmpBedElev < bedrockElev[e1]) && (outputFluxRatioToE1[ithCellIdx] > 0))
                            || ((tmpBedElev < bedrockElev[e2]) && (outputFluxRatioToE2[ithCellIdx] > 0)))
                    {
                        if ((bedrockElev[e1] > bedrockElev[e2]) && (outputFluxRatioToE1[ithCellIdx] > 0))
                        {
                            dBedrockElev[ithCellIdx] = bedrockElev[e1] - bedrockElev[ithCellIdx];
                        }
                        else
                        {
                            if (outputFluxRatioToE2[ithCellIdx] > 0)
                            {
                                dBedrockElev[ithCellIdx] = bedrockElev[e2] - bedrockElev[ithCellIdx];
                            }
                            else
                            {
                                dBedrockElev[ithCellIdx] = bedrockElev[e1] - bedrockElev[ithCellIdx];
                            }
                        }
                        
                        /* for warning and debug */
                        if (dBedrockElev[ithCellIdx] > 0)
                        {
                            /* for the intitial condition in which upstream bedrock
                             * elevation is lower than its downstream (e1, e2) */
                            if ((bedrockElev[ithCellIdx] < bedrockElev[e1])
                                || (bedrockElev[ithCellIdx] < bedrockElev[e2]))
                            {
                                mexWarnMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeDBedrockElev"
                                    ,"reversed dBedrockElev: diff with e1, %f; diff with e2, %f"
                                    ,bedrockElev[e1] - bedrockElev[ithCellIdx]
                                    ,bedrockElev[e2] - bedrockElev[ithCellIdx]);
                                dBedrockElev[ithCellIdx] = 0;
                            }
                            else
                            {
                                /* for debug */                                
                                mexErrMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeDBedrockElev"
                                        ,"negative dBedrockElev");
                            }                        
                        }           
                    }
                            
                    /* ���� ������ ������ [m^3/subDT] */
                    outputFlux[ithCellIdx] = inputFlux[ithCellIdx] + chanBedSed[ithCellIdx]
                            - (dBedrockElev[ithCellIdx] * CELL_AREA);
                    /* don't include flux due to bedrock incision */
                    dSedimentThick[ithCellIdx] = - (inputFlux[ithCellIdx] + chanBedSed[ithCellIdx])
                                                    / CELL_AREA;
                    if (sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx] < 0)
                    {
                        dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                        outputFlux[ithCellIdx]
                                = - (dSedimentThick[ithCellIdx] + dBedrockElev[ithCellIdx]) * CELL_AREA;
                    } 
                    /* �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT] */
                    dChanBedSed[ithCellIdx] = dSedimentThick[ithCellIdx] * CELL_AREA;
                    
                    /* for debug */
                    if (outputFlux[ithCellIdx] < 0)
                    {
                        mexErrMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeOutputFlux","negative output flux");
                    }
                }
            }

            /* B. ���� ������ ���� ���� ��(e1,e2)�� �������� �������� ���� */
            
            /* A) ���� ���� ��ݵ� ������ ������ [m^3/subDT]*/
            outputFluxToE1 = outputFluxRatioToE1[ithCellIdx] 
                * outputFlux[ithCellIdx];
            outputFluxToE2 = outputFluxRatioToE2[ithCellIdx]
                * outputFlux[ithCellIdx];

            /* B) ���� ���� flooded region�̶�� inputFloodedRegion��
             *    �������� �ݿ��ϰ� �׷��� �ʴٸ� ���� ���� ���� �ݿ��� */
            if ((mwSize)flood[e1] == FLOODED)
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
            
            if ((mwSize)flood[e2] == FLOODED)
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
            /* i��° ���� flooded region�� ���ⱸ��� ���� ������ �̿�����
             * �ʰ�, �ִ��Ϻΰ�� ���� �˰����� �̿��Ѵ�.��, SDSNbrY,
             * SDSNbrX�� ����Ű�� ���� ���� �������� ������ */

            /* (1) flooded region������ ������ ���Է��� flooded region��
             *    ���差�� �ʰ��ϴ��� Ȯ���ϰ� �̸� i��° ���� �������� �ݿ��� */
            if (inputFloodedRegion[ithCellIdx] 
                    > floodedRegionStorageVolume[ithCellIdx])
            {
                /* A. �ʰ��� ���, �ʰ����� ���ⱸ�� �������� ���� */
                inputFlux[ithCellIdx] = inputFlux[ithCellIdx]
                    + (inputFloodedRegion[ithCellIdx]
                    - floodedRegionStorageVolume[ithCellIdx]);
                /* B. flooded region�� ������ �������� ä�����ٰ� ǥ���� */
                isFilled[ithCellIdx] = true;
            }
            
            /* (2) i��° ���� ��������� Ȯ���� */
            if (hillslope[ithCellIdx] == true)                
            {
                /* A. ����̶��, ��ǥ���⿡ ���� ħ�ķ��� ���� */
                outputFlux[ithCellIdx] = transportCapacityForShallow[ithCellIdx];                
                dSedimentThick[ithCellIdx] 
                        = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx]) / CELL_AREA;
                
                /* to do: ��ݾ� ������ ������ ���� �ʴ� ������ ó���� */
                if ((sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx]) < 0)
                {
                    dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];                        
                    outputFlux[ithCellIdx] = sedimentThick[ithCellIdx] * CELL_AREA;                    
                }            
            }            
            else
            {
                /* B. ��õ�̶��, ��õ�� ���� ������� ���ϰ� �̸� ���� ���� �й��� */ 

                /* A) ������ ��ݴɷ��� �ϻ� ���������� ū ���� Ȯ���� */
                excessTransportCapacity /* ���Է� ���� ������ ��ݴɷ� [m^3/subDT] */
                    = transportCapacity[ithCellIdx] - inputFlux[ithCellIdx];
                if (excessTransportCapacity <= chanBedSed[ithCellIdx])
                {
                    /* (A) ������ ��ݴɷ��� �ϻ� ���������� �۴ٸ�, �������ȯ���� */
                    /* ���� ������ ������ [m^3/subDT] */
                    outputFlux[ithCellIdx] = transportCapacity[ithCellIdx];
                    /* b. ������ �β� ��ȭ�� [m/subDT] */
                    dSedimentThick[ithCellIdx] = (inputFlux[ithCellIdx] - outputFlux[ithCellIdx])
                                                    / CELL_AREA;
                    /* c. �ϵ� �� �ϻ� ������ ���� [m^3] */
                    dChanBedSed[ithCellIdx] = dSedimentThick[ithCellIdx] * CELL_AREA;
                    
                    /* for debug */
                    if (sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx] < 0)
                    {
                        mexErrMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeSedimentThick","negative sediment thickness");
                    }
                    if (outputFlux[ithCellIdx] < 0)
                    {
                        mexErrMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeOutputFlux","negative output flux");
                    }
                }
                else /* (excessTransportCapacity > chanBedSed[ithCellIdx) */
                {
                    /* (B) ������ ��ݴɷ��� �ϻ� ���������� ũ�� �и�����ȯ���� */
                    /* ��ݾ� �Ͻķ� [m/subDT] */
                    /* * ����: ���� ���� ��ݾ� �ϻ� ���� ����Ͽ� ��ݾ� �Ͻķ��� �����ϴ� ���� �߰��� */
                    dBedrockElev[ithCellIdx] = - (bedrockIncision[ithCellIdx] / CELL_AREA);
                   
                    /* prevent bedrock elevation from being lowered compared to downstream node */
                    tmpBedElev = bedrockElev[ithCellIdx] + dBedrockElev[ithCellIdx];
                    if (((tmpBedElev < bedrockElev[e1]) && (outputFluxRatioToE1[ithCellIdx] > 0))
                            || ((tmpBedElev < bedrockElev[e2]) && (outputFluxRatioToE2[ithCellIdx] > 0)))
                    {
                        if ((bedrockElev[e1] > bedrockElev[e2]) && (outputFluxRatioToE1[ithCellIdx] > 0))
                        {
                            dBedrockElev[ithCellIdx] = bedrockElev[e1] - bedrockElev[ithCellIdx];
                        }
                        else
                        {
                            if (outputFluxRatioToE2[ithCellIdx] > 0)
                            {
                                dBedrockElev[ithCellIdx] = bedrockElev[e2] - bedrockElev[ithCellIdx];
                            }
                            else
                            {
                                dBedrockElev[ithCellIdx] = bedrockElev[e1] - bedrockElev[ithCellIdx];
                            }
                        }
                        
                        /* for warning and debug */
                        if (dBedrockElev[ithCellIdx] > 0)
                        {
                            /* for the intitial condition in which upstream bedrock
                             * elevation is lower than its downstream (e1, e2) */
                            if ((bedrockElev[ithCellIdx] < bedrockElev[e1])
                                || (bedrockElev[ithCellIdx] < bedrockElev[e2]))
                            {
                                mexWarnMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeDBedrockElev"
                                    ,"reversed dBedrockElev: diff with e1, %f; diff with e2, %f"
                                    ,bedrockElev[e1] - bedrockElev[ithCellIdx]
                                    ,bedrockElev[e2] - bedrockElev[ithCellIdx]);
                                dBedrockElev[ithCellIdx] = 0;
                            }
                            else
                            {
                                /* for debug */                                
                                mexErrMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeDBedrockElev"
                                        ,"negative dBedrockElev");
                            }                        
                        }           
                    }
                            
                    /* ���� ������ ������ [m^3/subDT] */
                    outputFlux[ithCellIdx] = inputFlux[ithCellIdx] + chanBedSed[ithCellIdx]
                            - (dBedrockElev[ithCellIdx] * CELL_AREA);
                    /* don't include flux due to bedrock incision */
                    dSedimentThick[ithCellIdx] = - (inputFlux[ithCellIdx] + chanBedSed[ithCellIdx])
                                                    / CELL_AREA;
                    if (sedimentThick[ithCellIdx] + dSedimentThick[ithCellIdx] < 0)
                    {
                        dSedimentThick[ithCellIdx] = - sedimentThick[ithCellIdx];
                        outputFlux[ithCellIdx]
                                = - (dSedimentThick[ithCellIdx] + dBedrockElev[ithCellIdx]) * CELL_AREA;
                    } 
                    /* �ϵ� �� �ϻ� ������ ��ȭ�� [m^3/subDT] */
                    dChanBedSed[ithCellIdx] = dSedimentThick[ithCellIdx] * CELL_AREA;
                    
                    /* for debug */
                    if (outputFlux[ithCellIdx] < 0)
                    {
                        mexErrMsgIdAndTxt("EstimateDElevByFluvialProcess_m:negativeOutputFlux","negative output flux");
                    }
                }
            }
            
            /* (3) �ִ��Ϻΰ�� ������ ���� ���� ���� �������� �������� ���� */
            /* A. �ִ� �Ϻ� ��� ������ ����Ű�� ���� ���� ��ǥ
            * *  ����: MATLAB �迭 ���� ������ ���� '-1'�� ������ */
            next = (mwIndex)mexSDSNbrIndicies[ithCellIdx] - 1;            

            /* B. ���� ���� flooded region �̶�� inputFloodedRegion��
             *    �������� �ݿ��ϰ� �׷��� �ʴٸ� ���� ���� ���� �ݿ��� */
            if  ((mwSize)flood[next] == FLOODED )
            {
                /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                outlet = (mwIndex)mexSDSNbrIndicies[next] - 1;                                
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