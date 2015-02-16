class UsersController < ApplicationController
    before_action :skip_first_page, only: :new

    def new
        @bodyId = 'home'
        @is_mobile = mobile_device?

        @user = User.new

        respond_to do |format|
            format.html # new.html.erb
        end
    end

    def create
        # Get user to see if they have already signed up
        @user = User.find_by_email(params[:user][:email]);
            
        # If user doesnt exist, make them, and attach referrer
        if @user.nil?

            cur_ip = IpAddress.find_by_address(request.remote_ip)

            if !cur_ip
                cur_ip = IpAddress.create(
                    address: request.remote_ip,
                    count: 0
                )
            end

            if cur_ip.count > 2
                return redirect_to root_path
            else
                cur_ip.count = cur_ip.count + 1
                cur_ip.save
            end

            @user = User.new(email_params)

            @referred_by = User.find_by_referral_code(cookies[:h_ref])

            puts '------------'
            puts @referred_by.email if @referred_by
            puts params[:user][:email].inspect
            puts request.remote_ip.inspect
            puts '------------'

            if !@referred_by.nil?
                @user.referrer = @referred_by
            end

            @user.save
        end

        # Send them over refer action
        respond_to do |format|
            if !@user.nil?
                cookies[:h_email] = { value: @user.email }
                format.html { redirect_to '/refer-a-friend' }
            else
                format.html { redirect_to root_path, alert: "Something went wrong!" }
            end
        end
    end

    def refer
        email = cookies[:h_email]

        @bodyId = 'refer'
        @is_mobile = mobile_device?

        @user = User.find_by_email(email)

        respond_to do |format|
            if !@user.nil?
                format.html #refer.html.erb
            else
                format.html { redirect_to root_path, alert: "Something went wrong!" }
            end
        end
    end

    def policy
          
    end  

    def redirect
        redirect_to root_path, status: 404
    end

    private 

    def skip_first_page
        if !Rails.application.config.ended
            email = cookies[:h_email]
            if email and !User.find_by_email(email).nil?
                redirect_to '/refer-a-friend'
            else
                cookies.delete :h_email
            end
        end
    end

     private
    # Using a private method to encapsulate the permissible parameters is just a good pattern
    # since you'll be able to reuse the same permit list between create and update. Also, you
    # can specialize this method with per-user checking of permissible attributes.
    def email_params
      params.require(:user).permit(:email)
    end
end
