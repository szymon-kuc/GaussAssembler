using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Numerics;
using System;
using System.Linq;
using System.Windows.Forms;
using System.Threading;
using System.Data;

namespace GaussEliminationApp
{
    public partial class Form1 : Form
    {
        //SCIEŻKI DO DLL NIE RUSZAĆ NIE ZMIENIAĆ :)
        //Wiktor-PC D:\STUDIA\ja\gauss\x64\Debug
        //Wiktor-laptop C:\Users\Vikus\source\repos\GaussAssembler\x64\Debug\
        //Szymon-komp E:\Studia\JA\GaussAssembler\x64\Debug\Gauss.dll

        [DllImport(@"C:\Users\Vikus\source\repos\GaussAssembler\x64\Debug\Gauss.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void GaussEliminate(double[] matrix, int columns, int rows);

        private TextBox[,] inputBoxes;
        private Label[,] resultLabels;
        private Button btnCalculate;
        private ComboBox methodSelector; // Nowa kontrolka do wyboru metody
        private ComboBox matrixSizeSelector;
        private DataGridView resultGrid;
        private TextBox avgTimeTextBox;

        public Form1() 
        {
            InitializeForm(); // inicializacja GUI
        }
         
        private void InitializeForm()
        {
            matrixSizeSelector = new ComboBox
            {
                Items = { "3x3", "5x5","8x8" },
                SelectedIndex = 0,
                Location = new System.Drawing.Point(10, 10)
            };
            matrixSizeSelector.SelectedIndexChanged += MatrixSizeSelector_SelectedIndexChanged;
            this.Controls.Add(matrixSizeSelector);

            CreateTextBoxes();
            ResetResults();

            //przycisk do urchomienia obliczeń
            btnCalculate = new Button
            {
                Text = "Oblicz",
                Location = new System.Drawing.Point(10, 320)
            };
            btnCalculate.Click += btnCalculate_Click; //odwołanie do funkcji on click 
            this.Controls.Add(btnCalculate);

            this.AutoSize = true;
            this.AutoSizeMode = AutoSizeMode.GrowAndShrink;

            methodSelector = new ComboBox
            {
                Items = { "Metoda Asemblera", "Metoda C#" },
                SelectedIndex = 0,
                Location = new System.Drawing.Point(10, 280)
            };
            this.Controls.Add(methodSelector);
        }
        private void MatrixSizeSelector_SelectedIndexChanged(object sender, EventArgs e)
        {
            CreateTextBoxes();
       
        }
        private void ResetResults()
        {
            int p = 0;
            switch (matrixSizeSelector.SelectedIndex)
            {
                case 0: { p = 1; break; }
                case 1: { p = 2; break; }
                case 2: { p = 4; break; }
            }
            int selectedSize = matrixSizeSelector.SelectedIndex + 2 + p;
            if (resultLabels == null)
            {
                // Initialize resultLabels if it's null
                resultLabels = new Label[selectedSize, selectedSize + 1];
            }
            // Check if resultLabels is not null and has the same dimensions as selectedSize
            if (resultLabels != null && resultLabels.GetLength(0) == selectedSize && resultLabels.GetLength(1) == selectedSize + 1)
            {
                for (int i = 0; i < selectedSize; i++)
                {
                    for (int j = 0; j < selectedSize + 1; j++)
                    {
                        resultLabels[i, j].Text = "";
                   
                    }
                }
            }

            resultGrid = new DataGridView
            {
                Location = new System.Drawing.Point(10, 350),
                Size = new System.Drawing.Size(800, 120),
                ColumnCount = 3,
                Columns =
                {
                    new DataGridViewTextBoxColumn { Name = "Threads", HeaderText = "Threads" },
                    new DataGridViewTextBoxColumn { Name = "Time", HeaderText = "Time (ms)" },
                    new DataGridViewTextBoxColumn { Name = "AverageTime", HeaderText = "Average Time (ms)", ReadOnly = true }
                },
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                AllowUserToResizeColumns = false,
                AllowUserToResizeRows = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.AllCells,
                RowHeadersVisible = false,
                ColumnHeadersDefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter, Font = new System.Drawing.Font("Arial", 9.75F, FontStyle.Bold) },
                DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter }
            };
            this.Controls.Add(resultGrid);

            avgTimeTextBox = new TextBox
            {
                Location = new System.Drawing.Point(10, 380),
                Size = new System.Drawing.Size(400, 20),
                ReadOnly = true
            };
            this.Controls.Add(avgTimeTextBox);

        }
        private void CreateTextBoxes()
        {
            foreach (var control in this.Controls.OfType<TextBox>().ToArray())
            {
                this.Controls.Remove(control);
            }

            foreach (var control in this.Controls.OfType<Label>().ToArray())
            {
                this.Controls.Remove(control);
            }

            int p = 0;
            switch (matrixSizeSelector.SelectedIndex)
            {
                case 0: {  p = 1; break; }
                case 1: { p = 2; break; }
                case 2: { p = 4; break; }
            }
     
            int selectedSize = matrixSizeSelector.SelectedIndex + 2 + p;

            inputBoxes = new TextBox[selectedSize, selectedSize + 1];
            resultLabels = new Label[selectedSize, selectedSize + 1];

            for (int i = 0; i < selectedSize; i++)
            {
                for (int j = 0; j < selectedSize + 1; j++)
                {
                    inputBoxes[i, j] = new TextBox
                    {
                        Location = new System.Drawing.Point(10 + j * 60, 40 + i * 30),
                        Size = new System.Drawing.Size(50, 20)
                    };
                    this.Controls.Add(inputBoxes[i, j]);

                    resultLabels[i, j] = new Label
                    {
                        Location = new System.Drawing.Point(10 + (selectedSize + 1) * 60 + j * 60, 40 + i * 30),
                        Size = new System.Drawing.Size(50, 20),
                        Text = "",
                        TextAlign = ContentAlignment.MiddleCenter
                    };
                    this.Controls.Add(resultLabels[i, j]);
                }
            }
        }
        private async void btnCalculate_Click(object sender, EventArgs e)
        {
            btnCalculate.Enabled = false;
            btnCalculate.Text = "Obliczanie...";

            int methodSelected = methodSelector.SelectedIndex;

            try
            {
                int p = 0;
                switch (matrixSizeSelector.SelectedIndex)
                {
                    case 0: { p = 1; break; }
                    case 1: { p = 2; break; }
                    case 2: { p = 4; break; }
                }
                int selectedSize = matrixSizeSelector.SelectedIndex + 2 + p;
                double[,] matrix = new double[selectedSize, selectedSize + 1];

                for (int i = 0; i < selectedSize; i++)
                {
                    for (int j = 0; j < selectedSize + 1; j++)
                    {
                        matrix[i, j] = Convert.ToDouble(inputBoxes[i, j].Text);
                    }
                }

                DataTable resultsTable = new DataTable();
                resultsTable.Columns.Add("Threads", typeof(int));
                resultsTable.Columns.Add("Time (ms)", typeof(double));
                resultsTable.Columns.Add("AverageTime (ms)", typeof(double));

                int[] threadCounts = { 1, 2, 4, 8, 16, 32, 64 };
                int numRuns = 5; // Number of runs for averaging results

                //Tylko do wypisania wyniku
                if (methodSelected == 0)
                {
                    double[] flatMatrix = FlattenMatrix(matrix);
                    GaussEliminate(flatMatrix, selectedSize, selectedSize + 1);
                    UpdateUIWithResults(matrix, selectedSize);
                }
                else
                {
                    Eliminate(matrix);
                    UpdateUIWithResults(matrix, selectedSize);
                }

                await Task.Run(() =>
                {
                    foreach (int threads in threadCounts)
                    {
                        double totalMilliseconds = 0;

                        for (int run = 0; run < numRuns; run++)
                        {
                            Stopwatch stopwatch = Stopwatch.StartNew();

                            if (methodSelected == 0) // Założenie, że 0 to Gauss w ASM
                            {
                                double[] flatMatrix = FlattenMatrix(matrix);

                                Parallel.For(0, threads, new ParallelOptions { MaxDegreeOfParallelism = threads }, _ =>
                                {
                                    GaussEliminate(flatMatrix, selectedSize, selectedSize + 1);
                                });
                            }
                            else // Założenie, że każdy inny wybór to metoda w C#
                            {
                                var matrixCopy = (double[,])matrix.Clone();
                                Parallel.For(0, threads, new ParallelOptions { MaxDegreeOfParallelism = threads }, _ =>
                                {
                                    Eliminate(matrixCopy);
                                 
                                });
                            }

                            stopwatch.Stop();
                            totalMilliseconds += stopwatch.ElapsedMilliseconds;
                        }

                        double averageTime = totalMilliseconds / numRuns;
                        this.Invoke(new Action(() =>
                        {
                            resultsTable.Rows.Add(threads, totalMilliseconds, averageTime);
                        }));

                     
                           
                    }
                });

                resultGrid.DataSource = resultsTable;

                double avgTime = Convert.ToDouble(resultsTable.Compute("AVG([AverageTime (ms)])", string.Empty));
                avgTimeTextBox.Invoke(new Action(() => avgTimeTextBox.Text = $"Averaged Time: {avgTime} ms"));

            

            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
            finally
            {
                btnCalculate.Enabled = true;
                btnCalculate.Text = "Oblicz";
            }
        }

        private void UpdateUIWithResults(double[,] matrix, int selectedSize)
        {
            if (this.InvokeRequired)
            {
                this.Invoke(new Action(() => UpdateUIWithResults(matrix, selectedSize)));
            }
            else
            {
                // Wypisanie wyniku
                for (int i = 0; i < selectedSize; i++)
                {
                    for (int j = 0; j < selectedSize + 1; j++)
                    {
                        resultLabels[i, j].Text = matrix[i, j].ToString();
                    }
                }
            }
        }

        double[] FlattenMatrix(double[,] matrix)
        {
            int rows = matrix.GetLength(0);
            int cols = matrix.GetLength(1);
            double[] flatMatrix = new double[rows * cols];
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    flatMatrix[i * cols + j] = matrix[i, j];
                }
            }
            return flatMatrix;
        }




        //funkcja rozwiazania macierzy w c# 
        static void Eliminate(double[,] matrix)
        {
                int rows = matrix.GetLength(0);
                int cols = matrix.GetLength(1);
                // Wykonanie eliminacji Gaussa
                for (int pivot = 0; pivot < rows; pivot++)
                {
                    // Normalizacja pivotu
                    double pivotValue = matrix[pivot, pivot];
                    if (pivotValue == 0)
                    {
                        Console.WriteLine("Nie można rozwiązać - dzielenie przez zero.");
                        return;
                    }

                    for (int col = 0; col < cols; col++)
                    {
                        matrix[pivot, col] /= pivotValue;
                    }

                    // Eliminacja dla wierszy poniżej pivotu
                    for (int row = pivot + 1; row < rows; row++)
                    {
                        double factor = matrix[row, pivot];
                        for (int col = 0; col < cols; col++)
                        {
                            matrix[row, col] -= factor * matrix[pivot, col];
                        }
                    }
                }

                /*
                // Wsteczna substitucja
                double[] solution = new double[rows];
                for (int row = rows - 1; row >= 0; row--)
                {
                    solution[row] = matrix[row, cols - 1];
                    for (int i = row + 1; i < rows; i++)
                    {
                        solution[row] -= matrix[row, i] * solution[i];
                    }
                }

                // Wyświetlenie rozwiązania
                Console.WriteLine("Rozwiązanie układu równań:");
                for (int i = 0; i < solution.Length; i++)
                {
                    Console.WriteLine($"x{i + 1} = {solution[i]}");
                }
                */
            }
    }
}
