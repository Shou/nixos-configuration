{config, pkgs, lib, ...}: {
	users.users.valheim = {
		# Valheim puts save data in the home directory.
		home = "/var/lib/valheim";
	};

  # TODO FIXME: we also need to add a firewall port exception

	systemd.services.valheim = {
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			ExecStartPre = ''
				${pkgs.steamcmd}/bin/steamcmd \
					+login anonymous \
					+force_install_dir $STATE_DIRECTORY \
					+app_update 896660 \
					+quit
			'';
			ExecStart = ''
				${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ./valheim_server.x86_64 \
					-name "Valheim Explorers SEO" \
					-port 2456 \
					-world "Dedicated" \
					-password "campfire7" \
					-public 1
			'';
			Nice = "-5";
			Restart = "always";
			StateDirectory = "valheim";
			User = "valheim";
			WorkingDirectory = "/var/lib/valheim";
		};
		environment = {
			# linux64 directory is required by Valheim.
			LD_LIBRARY_PATH = "linux64:${pkgs.glibc}/lib";
		};
	};
}
