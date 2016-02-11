class App < Sinatra::Base

  include OpenGroupHelper

  get '/create_open_group' do
    if logged_in?
      erb :'open_groups/new'
    else
      redirect to('/')
    end
  end

  get '/open_group/:name' do
    # I can make some function to check
    # is the user has the permission to view the page


    if logged_in? and get_open_group(params[:name]).empty? != true

      # can make get_admin_id function

      @open_group = get_open_group(params[:name]).take
      @admin_id = get_open_group_admin_id(@open_group.id)
      @group_admin = User.find(@admin_id).username

      @has_joined = joined_open_group?(session[:user_id], @open_group.id)

      @posts = OpenGroupPost.where(open_group_id: @open_group.id)

      erb :'open_groups/show'
    else
      redirect to('/')
    end
  end

  post '/leave_open_group/:name' do
    if logged_in?
      @open_group = get_open_group(params[:name]).take
      has_joined = joined_open_group?(session[:user_id], @open_group.id)

      # can make get_admin_id function

      admin_id = get_open_group_admin_id(@open_group.id)

      if has_joined and session[:user_id] != admin_id
        delete_user_open_group_relations(session[:user_id], @open_group.id)
      end

      redirect to "/open_group/#{params[:name]}"
    else
      redirect to('/')
    end
  end

  post '/join_open_group/:name' do
    if logged_in?
      @open_group = get_open_group(params[:name]).take
      has_joined = joined_open_group?(session[:user_id], @open_group.id)

      if not has_joined
        join_user_to_open_group(session[:user_id], @open_group.id)
      end

      redirect to "/open_group/#{params[:name]}"
    else
      redirect to('/')
    end
  end

  post '/delete_open_group/:name' do
    if logged_in?
      @open_group = get_open_group(params[:name]).take
      has_joined = joined_open_group?(session[:user_id], @open_group.id)

      # can make get_admin_id function

      admin_id = get_open_group_admin_id(@open_group.id)

      if admin_id == session[:user_id]
        delete_user_open_group_relations(session[:user_id], @open_group.id)

        OpenGroupPost.where(open_group_id: @open_group.id).destroy_all
        OpenGroup.where(name: @open_group.name).take.destroy
      end

      redirect to "/open_group/#{params[:name]}"
    else
      redirect to('/')
    end
  end

  post '/create_open_group' do
    redirect to('/') if not logged_in?

    @open_group = OpenGroup.create(
      name: params[:open_group_name],
      description: params[:open_group_description])

    if @open_group.valid?
      join_user_to_open_group(session[:user_id], @open_group.id)

      redirect to('/')
    else
      puts "Error with open group creation."
      erb :'open_groups/new'
    end
  end

  post '/open_group/:name/post' do
    if logged_in?
      @open_group = get_open_group(params[:name]).take
      has_joined = joined_open_group?(session[:user_id], @open_group.id)

      if has_joined
        create_open_group_post(session[:user_id],
          @open_group.id, params[:open_group_post_content])
      end

    redirect to "open_group/#{params[:name]}"
    end

    redirect to('/')
  end
end
