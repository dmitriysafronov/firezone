defmodule FgHttpWeb.UserControllerTest do
  use FgHttpWeb.ConnCase, async: true
  import FgHttp.MockHelpers

  alias FgHttp.Users.Session

  @valid_create_attrs %{
    email: "valid@test",
    password: "password",
    password_confirmation: "password"
  }
  @invalid_create_attrs %{
    email: "test@test",
    password: "password",
    password_confirmation: "wrong_password"
  }
  @valid_update_attrs %{
    email: "test@test",
    password: "new_password",
    password_confirmation: "new_password"
  }
  @valid_email_attrs %{email: "test@test"}
  @invalid_email_attrs %{email: "invalid"}
  @empty_update_password_attrs %{
    email: "",
    password: "",
    password_confirmation: "",
    current_password: ""
  }
  @valid_update_password_attrs %{
    email: "test@test",
    password: "new_password",
    password_confirmation: "new_password",
    current_password: "test"
  }
  @invalid_update_password_attrs %{
    email: "test@test",
    password: "new_password",
    password_confirmation: "new_password",
    current_password: "wrong current password"
  }
  @invalid_update_attrs %{
    email: "test@test",
    password: "new_password",
    password_confirmation: "wrong_password"
  }

  describe "new when signups disabled" do
    setup do
      mock_disable_signup()
    end

    test "redirects to sign in with error message", %{unauthed_conn: conn} do
      test_conn = get(conn, Routes.user_path(conn, :new))

      assert redirected_to(test_conn) == Routes.session_path(test_conn, :new)

      assert get_flash(test_conn, :error) ==
               "Signups are disabled. Contact your administrator for access."
    end
  end

  describe "new when signups enabled" do
    setup do
      mock_enable_signup()
    end

    test "renders sign up form", %{unauthed_conn: conn} do
      test_conn = get(conn, Routes.user_path(conn, :new))

      assert html_response(test_conn, 200) =~ "Sign Up"
    end
  end

  describe "create when signups disabled" do
    setup do
      mock_disable_signup()
    end

    test "redirects to sign in with error message", %{unauthed_conn: conn} do
      test_conn = post(conn, Routes.user_path(conn, :create), user: @valid_create_attrs)

      assert redirected_to(test_conn) == Routes.session_path(test_conn, :new)

      assert get_flash(test_conn, :error) ==
               "Signups are disabled. Contact your administrator for access."
    end
  end

  describe "create when signups enabled" do
    setup do
      mock_enable_signup()
    end

    test "creates user when params are valid", %{unauthed_conn: conn} do
      test_conn = post(conn, Routes.user_path(conn, :create), user: @valid_create_attrs)

      assert redirected_to(test_conn) == "/devices"
      assert %Session{} = test_conn.assigns.session
    end

    test "renders errors when params are invalid", %{unauthed_conn: conn} do
      test_conn = post(conn, Routes.user_path(conn, :create), user: @invalid_create_attrs)

      assert html_response(test_conn, 200) =~ "Sign Up"
    end
  end

  describe "edit" do
    test "renders edit user form", %{authed_conn: conn} do
      test_conn = get(conn, Routes.user_path(conn, :edit))

      assert html_response(test_conn, 200) =~ "Edit Account"
    end
  end

  describe "show" do
    test "renders user details", %{authed_conn: conn} do
      test_conn = get(conn, Routes.user_path(conn, :show))

      assert html_response(test_conn, 200) =~ "Your Account"
    end
  end

  describe "update password" do
    test "updates password when params are valid", %{authed_conn: conn} do
      test_conn = put(conn, Routes.user_path(conn, :update), user: @valid_update_password_attrs)

      assert redirected_to(test_conn) == Routes.user_path(test_conn, :show)
    end

    test "renders errors when params are invalid", %{authed_conn: conn} do
      test_conn = put(conn, Routes.user_path(conn, :update), user: @invalid_update_password_attrs)

      assert html_response(test_conn, 200) =~ "is invalid: invalid password"
    end

    test "does nothing when password params are empty", %{authed_conn: conn} do
      test_conn = put(conn, Routes.user_path(conn, :update), user: @empty_update_password_attrs)

      assert redirected_to(test_conn) =~ Routes.user_path(test_conn, :show)
    end
  end

  describe "update" do
    test "updates email", %{authed_conn: conn} do
      test_conn = put(conn, Routes.user_path(conn, :update), user: @valid_email_attrs)

      assert redirected_to(test_conn) == Routes.user_path(test_conn, :show)
    end

    test "renders error when email is invalid", %{authed_conn: conn} do
      test_conn = put(conn, Routes.user_path(conn, :update), user: @invalid_email_attrs)

      assert html_response(test_conn, 200) =~ "has invalid format"
    end

    test "updates user when params are valid", %{authed_conn: conn} do
      test_conn = put(conn, Routes.user_path(conn, :update), user: @valid_update_attrs)

      assert redirected_to(test_conn) == Routes.user_path(test_conn, :show)
    end

    test "renders errors when params are invalid", %{authed_conn: conn} do
      test_conn = put(conn, Routes.user_path(conn, :update), user: @invalid_update_attrs)

      assert html_response(test_conn, 200) =~ "does not match password confirmation"
    end
  end

  describe "delete" do
    test "deletes user", %{authed_conn: conn} do
      test_conn = delete(conn, Routes.user_path(conn, :delete))
      assert redirected_to(test_conn) == "/"
    end
  end
end