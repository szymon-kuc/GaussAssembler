using System;
using System.Runtime.InteropServices;

class GaussElimination
{
    [DllImport(@"D:\STUDIA\ja\gaus\GaussAssembler\x64\Debug\DLL1.dll")]
    static extern void GaussEliminate(int[,] matrix);
     
    static void Main()
    {
        int[,] matrix = {
            { 1, 2, 3 },
            { 4, 5, 6 },
            { 7, 8, 9 }
        };

        Console.WriteLine("Original matrix:");
        PrintMatrix(matrix);

        Eliminate(matrix);

        Console.WriteLine("\nMatrix after Gauss elimination:");
        PrintMatrix(matrix);
    }

    static void Eliminate(int[,] matrix)
    {
        int rowCount = matrix.GetLength(0);
        int colCount = matrix.GetLength(1);

        for (int pivot = 0; pivot < rowCount - 1; pivot++)
        {
            for (int row = pivot + 1; row < rowCount; row++)
            {
                float factor = (float)matrix[row, pivot] / matrix[pivot, pivot];

                for (int col = pivot; col < colCount; col++)
                {
                    matrix[row, col] -= (int)(factor * matrix[pivot, col]);
                }
            }
        }
    }

    static void PrintMatrix(int[,] matrix)
    {
        int rowCount = matrix.GetLength(0);
        int colCount = matrix.GetLength(1);

        for (int i = 0; i < rowCount; i++)
        {
            for (int j = 0; j < colCount; j++)
            {
                Console.Write(matrix[i, j] + "\t");
            }
            Console.WriteLine();
        }
    }
}
