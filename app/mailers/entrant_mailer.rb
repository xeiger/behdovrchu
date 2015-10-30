class EntrantMailer < ActionMailer::Base
  default from: "behdovrchu@email.cz"

  def registration(entrant)
    @subject = "BĚH DO VRCHU - Informace k platbě startovného "
    @to = entrant.to_mail
    @entrant = entrant

    mail(to: @to, subject: @subject)
  end

end
