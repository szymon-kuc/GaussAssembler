using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace GaussEliminationApp
{
    public partial class Form1 : Form
    {
        [DllImport(@"E:\Studia\JA\GaussAssembler\x64\Debug\Gauss.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void GaussEliminate(int[] matrix);

        private TextBox[] inputBoxes = new TextBox[9];
        private Label[] resultLabels = new Label[9];
        private Button btnCalculate;

        public Form1()
        {
      
            InitializeForm();
        }

        private void InitializeForm()
        {
            // Inicjalizacja pól tekstowych dla wprowadzania danych macierzy
            for (int i = 0; i < 9; i++)
            {
                inputBoxes[i] = new TextBox();
                inputBoxes[i].Location = new System.Drawing.Point(10 + (i % 3) * 60, 10 + (i / 3) * 30);
                inputBoxes[i].Size = new System.Drawing.Size(50, 20);
                this.Controls.Add(inputBoxes[i]);
            }

            // Przycisk do obliczeń
            btnCalculate = new Button();
            btnCalculate.Text = "Oblicz";
            btnCalculate.Location = new System.Drawing.Point(10, 100);
            btnCalculate.Click += new EventHandler(btnCalculate_Click);
            this.Controls.Add(btnCalculate);

            // Etykiety do wyświetlania wyników
            for (int i = 0; i < 9; i++)
            {
                resultLabels[i] = new Label();
                resultLabels[i].Location = new System.Drawing.Point(10 + (i % 3) * 60, 130 + (i / 3) * 30);
                resultLabels[i].Size = new System.Drawing.Size(50, 20);
                this.Controls.Add(resultLabels[i]);
            }

            // Ustawienia formularza
            this.AutoSize = true;
            this.AutoSizeMode = AutoSizeMode.GrowAndShrink;
        }

        private void btnCalculate_Click(object sender, EventArgs e)
        {
            int[] matrix = new int[9];

            try
            {
                for (int i = 0; i < 9; i++)
                {
                    matrix[i] = Convert.ToInt32(inputBoxes[i].Text);
                }

                GaussEliminate(matrix);

                for (int i = 0; i < 9; i++)
                {
                    resultLabels[i].Text = matrix[i].ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
        }
    }
}
