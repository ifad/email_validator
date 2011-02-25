# encoding: utf-8
require 'active_model'
require 'resolv'

class EmailValidator < ActiveModel::EachValidator

  local_part_special_chars = Regexp.escape('!#$%&\'*-/=?+-^_`{|}~')
  local_part_unquoted      = '([[:alnum:]'   + local_part_special_chars + ']+[\.\+])*[[:alnum:]' + local_part_special_chars + '+]+'
  local_part_quoted        = '\"([[:alnum:]' + local_part_special_chars + '\.]|\\\\[\x00-\xFF])*\"'
  Pattern   = Regexp.new('\A(' + local_part_unquoted + '|' + local_part_quoted + '+)@(((\w+\-+[^_])|(\w+\.[a-z0-9-]*))*([a-z0-9-]{1,63})\.[a-z]{2,6}(?:\.[a-z]{2,6})?\Z)', Regexp::EXTENDED | Regexp::IGNORECASE, 'n')

  def validate_email_domain(domain)
    Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::MX).size > 0
    end

  rescue Errno::ECONNREFUSED, NoMethodError
    # DNS is not available - thus return true
    true
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
  # * <tt>multiple</tt>         - Allow multiple e-mail addresses, separated by +Separator+
  #                               (default: false)
  # * <tt>multiple_message</tt> - A custom error message shown when there are 2 or more addresses
  #                               to validate and one or more is invalid
  #                               (default: "appears to contain an invalid e-mail address)
  #
  # * <tt>local_length</tt>     - Maximum number of characters allowed in the local part
  #                               (default: 64)
  # * <tt>domain_length</tt>    - Maximum number of characters allowed in the domain part
  #                               (default: 255)
  def validate_each(record, attribute, value)
    options = default_options.update(self.options)
    return if value.blank? # Use :presence => true

    error = options[:multiple] ? validate_many(value, options) : validate_one(value, options)
    record.errors.add(attribute, :invalid, :message => error, :value => value) if error
  end

  private
    def default_options
      { :message          => I18n.t(:invalid_email_address,    :scope => [:activerecord, :errors, :messages], :default => 'does not appear to be a valid e-mail address'),
        :multiple_message => I18n.t(:invalid_multiple_email,   :scope => [:activerecord, :errors, :messages], :default => 'appears to contain an invalid e-mail address'),
        :mx_message       => I18n.t(:unroutable_email_address, :scope => [:activerecord, :errors, :messages], :default => 'is not routable'),
        :check_mx         => false,
        :with             => Pattern,
        :local_length     => 64,
        :domain_length    => 255
      }
    end

    def validate_many(value, options)
      emails = value.split(Separator)
      errors = emails.map {|addr| validate_one(addr, options)}
      errors.compact!
      options[emails.size == 1 ? :message : :multiple_message] unless errors.empty?
    end

    def validate_one(value, options)
      local, domain = value.split('@', 2)
      if local.nil?  || local.length  > options[:local_length]  or
         domain.nil? || domain.length > options[:domain_length] or
         value !~ options[:with]
        options[:message]

      elsif options[:check_mx] && !validate_email_domain(domain)
        options[:mx_message]

      end
    end
end
