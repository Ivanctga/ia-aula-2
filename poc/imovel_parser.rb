require 'nokogiri'

# Classe para armazenar os dados de um imóvel
class Imovel
  attr_accessor :codigo, :codigo_auxiliar, :titulo, :tipo, :subtipo, :finalidade, 
                :endereco, :numero, :bairro, :cidade, :estado, :cep, 
                :preco_venda, :preco_locacao, :area_util, :area_total,
                :dormitorios, :suites, :banheiros, :vagas,
                :data_cadastro, :data_atualizacao

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
  end

  def to_s
    <<-EOS
    Código: #{codigo} (#{codigo_auxiliar})
    Título: #{titulo}
    Tipo: #{tipo} - #{subtipo} (#{finalidade})
    Endereço: #{endereco}, #{numero} - #{bairro}, #{cidade}/#{estado} - CEP: #{cep}
    Preço venda: R$ #{preco_venda}
    Preço locação: R$ #{preco_locacao}
    Área: #{area_util}m² (útil) / #{area_total}m² (total)
    Quartos: #{dormitorios} (#{suites} suítes) | Banheiros: #{banheiros} | Vagas: #{vagas}
    Cadastrado em: #{data_cadastro} | Atualizado em: #{data_atualizacao}
    EOS
  end
end

# Classe para carregar e processar o XML
class ImoveisXmlParser
  def initialize(xml_file_path)
    @xml_content = File.read(xml_file_path)
    @doc = Nokogiri::XML(@xml_content)
  end

  def parse_imoveis
    imoveis = []
    
    # Seleciona todos os nós de imóveis
    @doc.xpath('//Imovel').each do |imovel_node|
      imovel = Imovel.new(
        codigo: text_content(imovel_node, 'CodigoImovel'),
        codigo_auxiliar: text_content(imovel_node, 'CodigoImovelAuxiliar'),
        titulo: text_content(imovel_node, 'TituloImovel'),
        tipo: text_content(imovel_node, 'TipoImovel'),
        subtipo: text_content(imovel_node, 'SubTipoImovel'),
        finalidade: text_content(imovel_node, 'Finalidade'),
        endereco: text_content(imovel_node, 'Endereco'),
        numero: text_content(imovel_node, 'Numero'),
        bairro: text_content(imovel_node, 'Bairro'),
        cidade: text_content(imovel_node, 'Cidade'),
        estado: text_content(imovel_node, 'Estado'),
        cep: text_content(imovel_node, 'CEP'),
        preco_venda: text_content(imovel_node, 'PrecoVenda'),
        preco_locacao: text_content(imovel_node, 'PrecoLocacao'),
        area_util: text_content(imovel_node, 'AreaUtil'),
        area_total: text_content(imovel_node, 'AreaTotal'),
        dormitorios: text_content(imovel_node, 'QtdDormitorios'),
        suites: text_content(imovel_node, 'QtdSuites'),
        banheiros: text_content(imovel_node, 'QtdBanheiros'),
        vagas: text_content(imovel_node, 'QtdVagas'),
        data_cadastro: text_content(imovel_node, 'DataCadastro'),
        data_atualizacao: text_content(imovel_node, 'DataAtualizacao')
      )
      
      imoveis << imovel
    end
    
    imoveis
  end
  
  def parse_lancamentos
    lancamentos = []
    
    @doc.xpath('//Lancamento').each do |lancamento_node|
      lancamento = {
        codigo: text_content(lancamento_node, 'codigoLancamento'),
        nome: text_content(lancamento_node, 'nome'),
        tipo: text_content(lancamento_node, 'tipo'),
        cidade: text_content(lancamento_node, 'cidade'),
        estado: text_content(lancamento_node, 'estado'),
        bairro: text_content(lancamento_node, 'bairro'),
        endereco: text_content(lancamento_node, 'endereco'),
        numero: text_content(lancamento_node, 'numero'),
        valor_minimo: text_content(lancamento_node, 'valorMinimo'),
        valor_maximo: text_content(lancamento_node, 'valorMaximo'),
        previsao_entrega: text_content(lancamento_node, 'previsaoEntrega'),
        construtora: text_content(lancamento_node, 'construtora'),
        dormitorios_min: text_content(lancamento_node, 'dormitoriosMin'),
        dormitorios_max: text_content(lancamento_node, 'dormitoriosMax')
      }
      
      lancamentos << lancamento
    end
    
    lancamentos
  end
  
  private
  
  def text_content(node, xpath)
    element = node.at_xpath(xpath)
    element ? element.text : nil
  end
end

# Usar o parser para carregar e processar o XML
begin
  parser = ImoveisXmlParser.new('paste.txt')
  imoveis = parser.parse_imoveis
  lancamentos = parser.parse_lancamentos
  
  puts "Encontrados #{imoveis.length} imóveis:"
  imoveis.each_with_index do |imovel, index|
    puts "\n--- Imóvel #{index + 1} ---"
    puts imovel
  end
  
  puts "\nEncontrados #{lancamentos.length} lançamentos:"
  lancamentos.each_with_index do |lancamento, index|
    puts "\n--- Lançamento #{index + 1} ---"
    puts "Código: #{lancamento[:codigo]}"
    puts "Nome: #{lancamento[:nome]}"
    puts "Endereço: #{lancamento[:endereco]}, #{lancamento[:numero]} - #{lancamento[:bairro]}, #{lancamento[:cidade]}/#{lancamento[:estado]}"
    puts "Valores: R$ #{lancamento[:valor_minimo]} a R$ #{lancamento[:valor_maximo]}"
    puts "Dormitórios: #{lancamento[:dormitorios_min]} a #{lancamento[:dormitorios_max]}"
    puts "Construtora: #{lancamento[:construtora]}"
    puts "Previsão de entrega: #{lancamento[:previsao_entrega]}"
  end
  
rescue => e
  puts "Erro ao processar o XML: #{e.message}"
  puts e.backtrace
end