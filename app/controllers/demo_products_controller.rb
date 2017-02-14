class DemoProductsController < ApplicationController

  # GET /demoproducts
  # GET /demoproducts.xml
  def index
    @demoproducts = DemoProduct.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @demoproducts }
    end
  end

  # GET /demoproducts/1
  # GET /demoproducts/1.xml
  def show
    @demoproduct = DemoProduct.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @demoproduct }
    end
  end

  # GET /demoproducts/new
  # GET /demoproducts/new.xml
  def new
    @demoproduct = DemoProduct.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @demoproduct }
    end
  end

  # GET /demoproducts/1/edit
  def edit
    @demoproduct = DemoProduct.find(params[:id])
  end

  # POST /demoproducts
  # POST /demoproducts.xml
  def create
    product = params[:demoproduct]
    logo = product['logo_temp'].read
    
    @demoproduct = DemoProduct.new()
    @demoproduct.logo = logo
    @demoproduct.name = product['name']
    @demoproduct.auth_key = product['auth_key']
    @demoproduct.mail_template = product['mail_template']
    @demoproduct.contact_mail = product['contact_mail']
    @demoproduct.mail_subject = product['mail_subject']
    @demoproduct.sales_mail = product['sales_mail']
    respond_to do |format|
      if @demoproduct.save
        flash[:notice] = 'DemoProduct was successfully created.'
        format.html { redirect_to(@demoproduct) }
        format.xml  { render :xml => @demoproduct, :status => :created, :location => @demoproduct }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @demoproduct.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /demoproducts/1
  # PUT /demoproducts/1.xml
  def update
    @demoproduct = DemoProduct.find(params[:id])
    product = params[:demoproduct]
    @demoproduct.name = product['name']
    @demoproduct.auth_key = product['auth_key']
    @demoproduct.mail_template = product['mail_template']
    @demoproduct.contact_mail = product['contact_mail']    
    @demoproduct.mail_subject = product['mail_subject']
    @demoproduct.sales_mail = product['sales_mail']    
    if !product['logo_temp'].nil? && product['logo_temp'] != ""
        logo = product['logo_temp'].read
        @demoproduct.logo = logo
    end
    
    respond_to do |format|
      if @demoproduct.save
        flash[:notice] = 'DemoProduct was successfully updated.'
        format.html { redirect_to(@demoproduct) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @demoproduct.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /demoproducts/1
  # DELETE /demoproducts/1.xml
  def destroy
    @demoproduct = DemoProduct.find(params[:id])
    @demoproduct.destroy

    respond_to do |format|
      format.html { redirect_to(demoproducts_url) }
      format.xml  { head :ok }
    end
  end
  
  def product_logo
     prodcut = DemoProduct.find(params[:id])
     send_data(prodcut.logo, :type => 'image/png', :disposition => 'inline') 
  end  
end