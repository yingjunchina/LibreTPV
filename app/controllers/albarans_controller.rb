class AlbaransController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Albaranes de Proveedores" if :seccion == "proveedores"
    flash[:mensaje] = "Listado de Compras" if :seccion == "clientes"
    flash[:mensaje] = "Listado de Truekes" if :seccion == "trueke"
    redirect_to :action => :listado
  end

  def listado
    @albarans = Albaran.all
  end

  def editar
    if params[:id]
      @albaran = Albaran.find(params[:id])
      @albaran_lineas = @albaran.albaran_lineas
      @importe_total = 0;
      @albaran_lineas.each { |linea| @importe_total += (linea.producto.precio * linea.cantidad * (1 - linea.descuento.to_f/100) ) }
      params[:update] = 'lineas_albaran'
      params[:albaran_id] = @albaran.id
      render :action => :modificar
    else
      @proveedores = Proveedor.all
    end
  end

  def modificar
    @albaran = params[:id] ? Albaran.find(params[:id]) : Albaran.new
    @albaran.update_attributes params[:albaran]
    redirect_to :action => :editar, :id => @albaran.id
  end

  # Segun la seccion borramos productos o los incluimos
  def aceptar_albaran
    albaran = Albaran.find_by_id params[:id]
    if albaran && !albaran.cerrado
      albaran.cerrado = true
      albaran.save
      lineas = albaran.albaran_lineas
      if :seccion == "clientes" || :seccion == "trueke"
        multiplicador = -1
      else
        multiplicador = 1
      end
      lineas.each do |linea|
        producto=Producto.find_by_id(linea.producto_id)
        producto.cantidad += (linea.cantidad * multiplicador)
        producto.save 
      end
    end
    flash[:mensaje] = "Albaran aceptado!"
    redirect_to :action => :listado
  end

  def borrar
    albaran = Albaran.find_by_id params[:id]
    if albaran
      if albaran.cerrado
        lineas = albaran.albaran_lineas
        if :seccion == "clientes" || :seccion == "trueke"
          multiplicador = 1
        else
          multiplicador = -1
        end
        lineas.each do |linea|
          producto=Producto.find_by_id(linea.producto_id)
          producto.cantidad += (linea.cantidad * multiplicador)
          producto.save  
        end
      end
      albaran.destroy
    end
    flash[:error] = albaran
    redirect_to :action => :listado
  end

end
