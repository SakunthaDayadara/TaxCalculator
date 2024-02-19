class TaxesController < ApplicationController
  before_action :set_tax, only: %i[ show edit update destroy ]


  # GET /taxes or /taxes.json
  def index
    @taxes = Tax.all
  end

  # GET /taxes/1 or /taxes/1.json
  def show
  end

  # GET /taxes/new
  def new
    @tax = Tax.new
  end

  # GET /taxes/1/edit
  def edit
  end

  # POST /taxes or /taxes.json
  def create
    @tax = Tax.new(tax_params)

    respond_to do |format|
      if @tax.save
        calculate_tax_deduction_and_net_income
        format.html { redirect_to tax_url(@tax), notice: "Tax was successfully created." }
        format.json { render :show, status: :created, location: @tax }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tax.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxes/1 or /taxes/1.json
  def update
    respond_to do |format|
      if @tax.update(tax_params)
        format.html { redirect_to tax_url(@tax), notice: "Tax was successfully updated." }
        format.json { render :show, status: :ok, location: @tax }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tax.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxes/1 or /taxes/1.json
  def destroy
    @tax.destroy

    respond_to do |format|
      format.html { redirect_to taxes_url, notice: "Tax was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tax
      @tax = Tax.find(params[:id])
    end



  def calculate_tax_deduction_and_net_income
    gross_income = @tax.grossincome

    # Taxable Income Range (LKR) and Tax Rate (%)
    tax_brackets = [
      { range: (0..100_000), rate: 0 },
      { range: (100_001..141_667), rate: 6 },
      { range: (141_668..183_333), rate: 12 },
      { range: (183_334..225_000), rate: 18 },
      { range: (225_001..266_667), rate: 24 },
      { range: (266_668..308_333), rate: 30 },
      { range: (308_334..Float::INFINITY), rate: 36 }
    ]

    # Calculate tax based on tax brackets
    tax_amount = 0
    remaining_income = gross_income

    tax_brackets.each do |bracket|
      if remaining_income <= 0
        break
      elsif bracket[:range].include?(remaining_income)
        taxable_amount = [remaining_income - bracket[:range].first, 0].max
        tax_amount += (taxable_amount * bracket[:rate] / 100)
        remaining_income -= taxable_amount
      else
        taxable_amount = bracket[:range].last - bracket[:range].first
        tax_amount += (taxable_amount * bracket[:rate] / 100)
        remaining_income -= taxable_amount
      end
    end

    # EPF/ETF deductions
    epf_deduction = gross_income * 0.08
    employer_epf_contribution = gross_income * 0.03

    # Net income after tax and EPF deductions
    net_income = gross_income - tax_amount - epf_deduction

    # Update tax object with calculated values
    @tax.taxdeduction = tax_amount
    @tax.epfdeduction = epf_deduction
    @tax.employerepfcontribution = employer_epf_contribution
    @tax.netincome = net_income

    @tax.save
  end

    # Only allow a list of trusted parameters through.
    def tax_params
      params.require(:tax).permit(:grossincome)
    end
end
