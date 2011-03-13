class PagoController < ApplicationController

  # --
  # METODOS AJAX DE PAGOS
  # --

  def pagos
    pago_pendiente
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
    end
  end

  def nuevo_pago
    @pago = params[:id] ?  Pago.find(params[:id]) : Pago.new
    factura = Factura.find_by_id params[:factura_id]
    @pago.factura = factura 
    pago_pendiente
    pagofecha = Time.now.to_s
    render :partial => "formulario", :update => params[:update]
  end

  def modificar_pago
    @pago = params[:id] ? Pago.find(params[:id]) : Pago.new
    @pago.update_attributes params[:pago]
    factura = Factura.find(@pago.factura_id)
    pago_pendiente
    if @pago_pendiente <= 0 && !factura.pagado
      factura.pagado = true
      factura.save
    end
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
      page.visual_effect :highlight, params[:update] , :duration => 6
      page.replace 'formulario_ajax', :inline => '<%= mensaje_error(@pago) %><br>'
      page.replace 'listado_campo_valor_pagado_' + params[:factura_id], :inline => '<div id="listado_campo_valor_pagado_<%= params[:factura_id]%>" class="listado_campo">true</div>' if @pago_pendiente <= 0
      page.call("Modalbox.resizeToContent")
    end
  end

  def eliminar_pago
    @pago = Pago.find(params[:id])
    @pago.destroy
    #@pagos = Factura.find(params[:factura_id]).pagos
    factura = Factura.find(params[:factura_id])
    pago_pendiente
    if @pago_pendiente > 0 && factura.pagado
      factura.pagado = false 
      factura.save
    end
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
      page.visual_effect :highlight, params[:update] , :duration => 6
      page.replace 'listado_campo_valor_pagado_' + params[:factura_id], :inline => '<div id="listado_campo_valor_pagado_<%= params[:factura_id] %>" class="listado_campo">&nbsp;</div>' if @pago_pendiente > 0
      page.replace_html 'MB_content', :inline => '<%= mensaje_error(@pago, :eliminar => true) %><br>'
      page.call("Modalbox.resizeToContent")
    end
  end

private
  def pago_pendiente
    factura = Factura.find(params[:factura_id])
    @pagos = factura.pagos
    @pago_pendiente = factura.importe
    @pagos.each { |pago| @pago_pendiente -= pago.importe }
  end

end