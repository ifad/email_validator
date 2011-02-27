# encoding: utf-8
require 'active_model'
require 'resolv'

class EmailValidator < ActiveModel::EachValidator

  local_part_special_chars = Regexp.escape('!#$%&\'*-/=?+-^_`{|}~')
  local_part_unquoted      = '([[:alnum:]'   + local_part_special_chars + ']+[\.\+])*[[:alnum:]' + local_part_special_chars + '+]+'
  local_part_quoted        = '\"([[:alnum:]' + local_part_special_chars + '\.]|\\\\[\x00-\xFF])*\"'
  Pattern   = Regexp.new('\A(' + local_part_unquoted + '|' + local_part_quoted + '+)@(((\w+\-+[^_])|(\w+\.[a-z0-9-]*))*([a-z0-9-]{1,63})\.[a-z]{2,6}(?:\.[a-z]{2,6})?\Z)', Regexp::EXTENDED | Regexp::IGNORECASE, 'n')

  def validate_email_domain(email)
    domain = email.match(/\@(.+)/)[1]
    Resolv::DNS.open do |dns|
      @mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX) + dns.getresources(domain, Resolv::DNS::Resource::IN::A)
    end
    @mx.size > 0 ? true : false
  end

  # Validates whether the specified value is a valid email address.  Returns nil if the value is valid, otherwise returns an array
  # containing one or more validation error messages.
  #
  # Configuration options:
  # * <tt>message</tt>          - A custom error message
  #                               (default: "does not appear to be a valid e-mail address")
  # * <tt>check_mx</tt>         - Check for MX records
  #                               (default: false)
  # * <tt>mx_message</tt>       - A custom error message when an MX record validation fails
  #                               (default: "is not routable.")
  # * <tt>with</tt>             - The regex to use for validating the format of the email address
  #                               (default: +Pattern+)</tt>
  # * <tt>local_length</tt>     - Maximum number of characters allowed in the local part
  #                               (default: 64)
  # * <tt>domain_length</tt>    - Maximum number of characters allowed in the domain part
  #                               (default: 255)
  def validate_each(record, attribute, value)
    options = {
      :message    => I18n.t(:invalid_email_address, :scope => [:activerecord, :errors, :messages], :default => 'does not appear to be a valid e-mail address'),
      :check_mx   => false,
      :mx_message => I18n.t(:email_address_not_routable, :scope => [:activerecord, :errors, :messages], :default => 'is not routable'),
      :with       => Regex
    }.update(self.options)

    return if value.blank? # Use :presence => true

    record.errors[attribute] =
      if !value =~ options[:with]
        options[:message]
      elsif options[:check_mx] && !validate_email_domain(value)
        options[:mx_message]
      end
  end
end
