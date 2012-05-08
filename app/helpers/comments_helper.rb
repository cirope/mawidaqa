module CommentsHelper
  def comment_file_identifier(comment)
    comment.file.identifier || comment.file_identifier if comment.file?
  end
end