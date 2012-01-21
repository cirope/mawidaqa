class FilesController < ApplicationController
  before_filter :authenticate_user!
  
  def download
    file = (PRIVATE_PATH + params[:path].to_s).expand_path

    if file.exist? && file.file? && file.to_s.start_with?(PRIVATE_PATH.to_s)
      mime_type = Mime::Type.lookup_by_extension(File.extname(file)[1..-1])
      
      response.headers['Last-Modified'] = File.mtime(file).httpdate
      response.headers['Cache-Control'] = 'private, no-store'

      send_file file, type: (mime_type || 'application/octet-stream')
    else
      redirect_to documents_url, notice: t('view.documents.non_existent')
    end
  end
end
