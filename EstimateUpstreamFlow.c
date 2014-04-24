/* 
 * EstimateUpstreamFlow.c
 *
 * flooded region�� ������ ������ ������� ��� �������κ����� ������ ���� ��
 * ������ ���ϴ� �Լ�. AccumulateUpstreamFlow �Լ��� for �ݺ������� C�� ������
 * * ����: ���� ��� ���� ���� �� ������ �ʿ����� �����Ƿ� �ּ� ó����
 *
 * [upstreamDischarge1 ...              0 ��� �������κ����� ���� [m^3]
 * ,inputDischarge ...                  1 ��� �������κ����� ���� [m^3]
 * ,dischargeInputInFloodedRegion ...   2 flooded region������ ����
 * ,isOverflowing ...                   3 flooded region ���差 �ʰ� �±�
 * ,upstreamCellsNo ...                 4 ��� ������ ���� �� ����
 * ,inputCellsNo ...                    5 ��� ������ ���� �� ���� 
 * ] = EstimateUpstreamFlow ...
 * (CELL_AREA, ...                      0 �� ����
 * ,consideringCellsNo ...              1 ��� ���� ������ �� ������ ���ϴ� �� ��
 * ,annualRunoff)                       2 ���� ���ⷮ
 * -------------------------------- mexGetVariabelPtr �Լ��� �����ϴ� ������
 * upstreamDischarge1 ...               3 ��� �������κ����� ���ⷮ �ʱⰪ
 * mexSortedIndicies ...                4 �������� ���ĵ� ����
 * e1LinearIndicies ...                 5 ���� �� ����
 * e2LinearIndicies ...                 6 ���� �� ���� 
 * outputFluxRatioToE1 ...              7 ���� ������ ���� ����
 * outputFluxRatioToE2 ...              8 ���� ������ ���� ����
 * mexSDSNbrLinearIndicies ...          9 ���� �� ����
 * flood ...                            10 flooded region
 * floodedRegionStorageVolume ...       11 flooded region ���差 [m^3]
 * floodedRegionCellsNo ...             12 flooded region ���� �� ����
 * upstreamCellsNo ...                  13 ��� ������ ���� �� ���� �ʱⰪ
 *
 */

# include "mex.h"

/* ��� �Լ� ���� */
void EstimateUpstreamFlow(
    double * upstreamDischarge1,
    double * inputDischarge,
    double * dischargeInputInFloodedRegion,
    mxLogical * isOverflowing,
    /* double * upstreamCellsNo, */
    /* double * inputCellsNo, */
    int CELL_AREA,
    mwSize consideringCellsNo,
    double annualRunoff,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* �Է� ���� ����
     * ����: mxArray �ڷ��� ������ mexGetVariablePtr �Լ��� �̿��Ͽ�
     * ȣ���Լ��� �۾������� �ִ� �������� �����͸� �ҷ��� */
    /* ȣ���Լ� �۾������� ���� */
    mxArray         * mxArray3; /* upstreamDischarge1 */
    const mxArray   * mxArray4; /* mexSortedIndicies */
    const mxArray   * mxArray5; /* e1LinearIndicies */
    const mxArray   * mxArray6; /* e2LinearIndicies */
    const mxArray   * mxArray7; /* outputFluxRatioToE1 */
    const mxArray   * mxArray8; /* outputFluxRatioToE2 */
    const mxArray   * mxArray9; /* mexSDSNbrIndicies */
    const mxArray   * mxArray10; /* flood */
    const mxArray   * mxArray11; /* floodedRegionStorageVolume */
    const mxArray   * mxArray12; /* floodedRegionCellsNo */
    /* mxArray         * mxArray13; /* upstreamCellsNo */
    
    /* �Էº��� ���� �ڷ� */
    int CELL_AREA;
    mwSize consideringCellsNo;
    double annualRunoff;
    
    double * mexSortedIndicies;
    double * e1LinearIndicies;
    double * e2LinearIndicies;
    double * outputFluxRatioToE1;
    double * outputFluxRatioToE2;
    double * mexSDSNbrIndicies;
    double * flood;
    double * floodedRegionCellsNo;
    double * floodedRegionStorageVolume;
    
    /* ��� ���� ���� */
    double * upstreamDischarge1;
    double * inputDischarge;
    double * dischargeInputInFloodedRegion;
    mxLogical * isOverflowing;
    /*double * upstreamCellsNo; */
    /*double * inputCellsNo; */
    
    /* �ӽ� ���� ���� */
    mwSize mRows,nCols;
    
    /* �Է� ���� �ʱ�ȭ */      
    CELL_AREA           = (int) mxGetScalar(prhs[0]);
    consideringCellsNo  = (mwSize) mxGetScalar(prhs[1]);
    annualRunoff        = mxGetScalar(prhs[2]);
    
	mxArray3    = mexGetVariable("caller","upstreamDischarge1");    
    mxArray4    = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray5    = mexGetVariablePtr("caller","e1LinearIndicies");    
    mxArray6    = mexGetVariablePtr("caller","e2LinearIndicies");    
    mxArray7    = mexGetVariablePtr("caller","outputFluxRatioToE1");
    mxArray8    = mexGetVariablePtr("caller","outputFluxRatioToE2");
    mxArray9    = mexGetVariablePtr("caller","mexSDSNbrIndicies");
    mxArray10   = mexGetVariablePtr("caller","flood");
    mxArray11   = mexGetVariablePtr("caller","floodedRegionStorageVolume");
    mxArray12   = mexGetVariablePtr("caller","floodedRegionCellsNo");    
    /* mxArray13   = mexGetVariable("caller","upstreamCellsNo"); */
        
    /* upstreamDischarge1 */
    mexSortedIndicies           = mxGetPr(mxArray4);    
    e1LinearIndicies            = mxGetPr(mxArray5);    
    e2LinearIndicies            = mxGetPr(mxArray6);    
    outputFluxRatioToE1         = mxGetPr(mxArray7);    
    outputFluxRatioToE2         = mxGetPr(mxArray8);    
    mexSDSNbrIndicies           = mxGetPr(mxArray9);    
    flood                       = mxGetPr(mxArray10);    
    floodedRegionStorageVolume  = mxGetPr(mxArray11);
    floodedRegionCellsNo        = mxGetPr(mxArray12);    
    
    /* ��� ���� �ʱ�ȭ */
	plhs[0] = mxArray3;
	    
    mRows = (mwSize) mxGetM(plhs[0]);
    nCols = (mwSize) mxGetN(plhs[0]);
    
    plhs[1] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[3] = mxCreateLogicalMatrix(mRows,nCols);
    /* plhs[4] = mxArray13; */
    /* plhs[5] = mxCreateDoubleMatrix(mRows,nCols,mxREAL); */
    
    /* ��� ���� �ڷῡ �����͸� ���� */
    upstreamDischarge1              = mxGetPr(plhs[0]);
    inputDischarge                  = mxGetPr(plhs[1]);
    dischargeInputInFloodedRegion   = mxGetPr(plhs[2]);
    isOverflowing                   = mxGetLogicals(plhs[3]);    
    /* upstreamCellsNo                 = mxGetPr(plhs[4]); */
    /* inputCellsNo                    = mxGetPr(plhs[5]); */
    
    /* ���� ��ƾ ���� */
    EstimateUpstreamFlow(
        upstreamDischarge1,
        inputDischarge,
        dischargeInputInFloodedRegion,
        isOverflowing,
        /* upstreamCellsNo, */
        /* inputCellsNo, */
        CELL_AREA,
        consideringCellsNo,
        annualRunoff,
        mexSortedIndicies,
        e1LinearIndicies,
        e2LinearIndicies,
        outputFluxRatioToE1,
        outputFluxRatioToE2,
        mexSDSNbrIndicies,
        flood,
        floodedRegionCellsNo,
        floodedRegionStorageVolume);
}

void EstimateUpstreamFlow(
    double * upstreamDischarge1,
    double * inputDischarge,
    double * dischargeInputInFloodedRegion,
    mxLogical * isOverflowing,
    /* double * upstreamCellsNo, */
    /* double * inputCellsNo, */
    int CELL_AREA,
    mwSize consideringCellsNo,
    double annualRunoff,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * flood,
    double * floodedRegionCellsNo,
    double * floodedRegionStorageVolume)
{    
    /* �ӽ� ���� ���� */
    mwIndex ithCell,ithCellIdx,outlet,next,e1,e2;
    double outputDischargeToE1,outputDischargeToE2;
    /* double outputCellsNoToE1,outputCellsNoToE2; */

    const int FLOODED = 2; /* flooded region */
    const int TRUE = 1;

    /* (���� �� ������) ��� �������κ����� ������ ���� �� ������ ���� */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {
        /* 1. i��° �� ���� */
        /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;

        /* 2. ��� �������κ����� ������ ���� �� ������ ������ ���� ���� ���� �й��� */
        /* 1) i��° ���� flooded region ���ⱸ�� �ƴ϶��, ���� ������ ���� ����
         *    ���� �й���
         * 2) i��° ���� flooded region ���ⱸ���, mexSDSNbrIndicies�� ���� ����
         *    ���� �й��� */

        /* 1) i��° ���� flooded region ���ⱸ�� �ƴ϶��(�Ϲ����� ���) ���� ����
         *    ��ǥ ���ⷮ�� �� ���� 1�� ��� �������κ����� ������ ���� �� ������
         *    ���� ���Ͽ� ���� ������ ���� ���� ���� �й��� */
        if ((int) floodedRegionCellsNo[ithCellIdx] == 0)
        {
            /* (1) ��� �������κ��� ���ԵǴ� ������ ���� �� ������ ���� ���� ��ǥ
             *     ���ⷮ�� �� ���� 1�� ���� */
            upstreamDischarge1[ithCellIdx]
                = upstreamDischarge1[ithCellIdx] + inputDischarge[ithCellIdx];
            /*upstreamCellsNo[ithCellIdx]
            /*    = upstreamCellsNo[ithCellIdx] + inputCellsNo[ithCellIdx];

            /* (2) ������ ���� �� ������ ������ ���� ���� ����(e1,e2)�� �й��� */

            /* A. e1,e2�� ���Է��� ���� ������ ������ ���� �� ������ ���� */
            outputDischargeToE1
                = outputFluxRatioToE1[ithCellIdx] * upstreamDischarge1[ithCellIdx];
            outputDischargeToE2
                = outputFluxRatioToE2[ithCellIdx] * upstreamDischarge1[ithCellIdx];

            /*outputCellsNoToE1
             *    = outputFluxRatioToE1[ithCellIdx] * upstreamCellsNo[ithCellIdx];
             *outputCellsNoToE2
             *    = outputFluxRatioToE2[ithCellIdx] * upstreamCellsNo[ithCellIdx]; */

            /* B. ���� ���� flooded region�� �ش��ϴ��� Ȯ���غ���,
             *    flooded region�� �ش��Ѵٸ� ��� �������κ����� ������
             *    ���� �� ������ flooded region�� ���Է��� �ݿ��ϰ�,
             *    �ƴ϶�� ���� ���� ���Է��� �ݿ��� */

            /* ���� �� ����
             * * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
            e1 = (mwIndex) e1LinearIndicies[ithCellIdx] - 1;
            e2 = (mwIndex) e2LinearIndicies[ithCellIdx] - 1;        

            /* A) e1�� flooded region�� �ش��ϴ��� Ȯ���� */
            if ( (int) flood[e1] == FLOODED )
            {

                /* (A) e1�� flooded region�� �ش��Ѵٸ� ������ ���� �� ������
                 *     flooded region�� ���Է����� �ݿ���
                 * * ����: ������ �� ������ ó�� ����� ���� �ٸ�
                 *   ������ ��� flooded region�� ������ �ʰ����� ���ⱸ��
                 *   �������� ������ ���ⱸ�� ���Է��� �ٷ� ������ ���� */

                /* a. flooded region�� ���ⱸ ���� */
                /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                outlet = (mwIndex) mexSDSNbrIndicies[e1] - 1;

                /* b. ������ ���� ���� flooded region�� ���Է��� ����� */
                dischargeInputInFloodedRegion[outlet]
                  = dischargeInputInFloodedRegion[outlet] + outputDischargeToE1;

                /* c. ���� �� ������ ���� ���� ���ⱸ�� ���Է��� ����� */
                /* inputCellsNo[outlet] = inputCellsNo[outlet] + outputCellsNoToE1; */
            }
            else
            {
                /* (B) e1�� flooded region�� �ƴ϶��, e1�� ���Է��� ��� 
                 *     �������κ����� ������ ���� �� ������ ���� */
                inputDischarge[e1] = inputDischarge[e1] + outputDischargeToE1;

                /* inputCellsNo[e1] = inputCellsNo[e1] + outputCellsNoToE1; */
            }

            /* B) e2�� flooded region�� �ش��ϴ��� Ȯ���� */
            if ( (int) flood[e2] == FLOODED )
            {

                /* (A) e2�� flooded region�� �ش��Ѵٸ� ������ ���� �� ������ 
                 *     flooded region�� ���Է����� �ݿ���
                 * * ����: ������ �� ������ ó�� ����� ���� �ٸ�
                 *   ������ ��� flooded region�� ������ �ʰ����� ���ⱸ�� ��������
                 *   ������ ���ⱸ�� ���Է��� �ٷ� ������ ���� */

                /* a. flooded region�� ���ⱸ�� ��ǥ�� �ľ��� */
                /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                outlet = (mwIndex) mexSDSNbrIndicies[e2] - 1;

                /* b. ������ ���� ���� flooded region�� ���Է��� ����� */
                dischargeInputInFloodedRegion[outlet]
                    = dischargeInputInFloodedRegion[outlet] + outputDischargeToE2;

                /* c. ���� �� ������ ���� ���� ���ⱸ�� ���Է��� ����� */
                /* inputCellsNo[outlet] = inputCellsNo[outlet] + outputCellsNoToE2; */
            }
            else
            {
                /* (B) e2�� flooded region�� �ƴ϶��, e2�� ���Է��� ���
                 *     �������κ����� ������ ���� �� ������ ���� */
                inputDischarge[e2] = inputDischarge[e2] + outputDischargeToE2;

                /* inputCellsNo[e2] = inputCellsNo[e2] + outputCellsNoToE2; */

            }
        }
        /* (2) i��° ���� flooded region�� ���ⱸ��� ���� ������ �̿����� �ʰ�
         *     �ִ� �Ϻ� ��� ���� �˰����� �̿��Ѵ�. ��, SDSNbrIndicies�� 
         *     ����Ű�� ���� ���� ��� ������ ������ ���� ������ �й���
         *     �̴� ProcessSink �Լ����� ���ⱸ�� ������ flooded region�� �ٽ�
         *     ������ �ʵ��� SDSNbrY,SDSNbrX�� ������ ���߱� ������ */
        else
        {
            /* A. ��� �������κ����� ���Է��� flooded region�� �������� �ʰ��ϴ�
             *    ���� ���� */

            /* A) flooded region������ ���Է��� �������� �ʰ��ϴ��� Ȯ���ϰ�
             *    �ʰ��� ��� �ʰ����� ��� �������κ����� ���Է����� ������
             * * ����: ���� ���������� �󵵰� 1�� ������ ���� �� �߻��� Ȯ���� ����
             *   ������ ���⼭�� ���������� 1�⿡ �� �����ִ� ������ ������ */

            /* (A) flooded region�� ���Է��� ��ǥ���ⷮ �հ踦 ���� */
            dischargeInputInFloodedRegion[ithCellIdx]
                = dischargeInputInFloodedRegion[ithCellIdx]
                + floodedRegionCellsNo[ithCellIdx] * annualRunoff * CELL_AREA;

            /* (B) flooded region�� �������� ���Է��� ���� */
            if (dischargeInputInFloodedRegion[ithCellIdx]
                > floodedRegionStorageVolume[ithCellIdx])
            {
                /* a. flooded region�� �ʰ� ���Է��� i��° ���� ���Է��� ���� */
                inputDischarge[ithCellIdx] = inputDischarge[ithCellIdx]
                    + ( dischargeInputInFloodedRegion[ithCellIdx]
                    - floodedRegionStorageVolume[ithCellIdx] );

                /* b. flooded region�� �������� �ʰ��Ͽ��ٰ� ǥ���� */
                isOverflowing[ithCellIdx] = TRUE;
            }

            /* (C) flooded region�� �ʰ� ���Է��� ���� */
            upstreamDischarge1[ithCellIdx] 
                = upstreamDischarge1[ithCellIdx] + inputDischarge[ithCellIdx];

            /* B. ��� �������κ��� �����ϴ� ���� ������ ����
             * * ����: i ��° ���� ���ⱸ�̹Ƿ� flooded region�� �� ���� ������ */
            /* upstreamCellsNo[ithCellIdx] = upstreamCellsNo[ithCellIdx]
             *     + inputCellsNo[ithCellIdx] + floodedRegionCellsNo[ithCellIdx]; */

            /* C. ������ ���� ������ ������ ���� ���� ���� �й���
             * A) ���� �� ����
             * * ����: ���� ������ �̿����� �ʰ�, SDSNbrIndicies�� ���� ���� ����
             *   �й��� */
            /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
            next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;

            /* B) ���� ���� flooded region�� �ش��ϴ��� Ȯ���غ���, flooded
             *    region�� �ش��Ѵٸ� ��� �������κ����� ������ ���� �� ������
             *    flooded region�� ���Է��� �ݿ��ϰ�, �ƴ϶�� ���� ���� ���Է���
             *    �ݿ��� */

            /* (A) ���� ���� flooded region�� �ش��ϴ��� Ȯ���� */
            if  ( (int) flood[next] == FLOODED )
            {
                /* a. ���� ���� flooded region�̶��, ������ ���� �� ������
                 *    flooded region�� ���Է����� �ݿ���
                 * * ���� : ������ ���� ������ ó�� ����� �ٸ� */

                /* a) flooded region�� ���ⱸ ���� */
                /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                outlet = (mwIndex) mexSDSNbrIndicies[next] - 1;

                /* b) ������ ���� ���� flooded region�� ���Է��� ����� */
                dischargeInputInFloodedRegion[outlet]
                    = dischargeInputInFloodedRegion[outlet]
                    + upstreamDischarge1[ithCellIdx];

                /* c) ���� �� ������ ���� ���� ���ⱸ�� ���Է��� ����� */
                /* inputCellsNo[outlet] 
                /*     = inputCellsNo[outlet] + upstreamCellsNo[ithCellIdx]; */
            }
            else
            {
                /* b. ���� ���� flooded region�� �ƴ϶��, ���� ���� ���Է���
                 *    ��� �������κ����� ������ ���� �� ������ ���� */
                inputDischarge[next]
                    = inputDischarge[next] + upstreamDischarge1[ithCellIdx];

                /* inputCellsNo[next] 
                /*     = inputCellsNo[next] + upstreamCellsNo[ithCellIdx]; */
            }
        } /* if (floodedRegionCellsNo[ithCellIdx] == 0) */
    } /* for ithCell */
}
